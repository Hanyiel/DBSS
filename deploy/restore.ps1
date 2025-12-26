param(
  [Parameter(Mandatory = $true)]
  [string]$FromDir,
  [switch]$SkipMySQL,
  [switch]$SkipPostgres,
  [switch]$SkipOracle
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Read-DotEnv([string]$Path) {
  $map = @{}
  if (!(Test-Path $Path)) { throw "Missing env file: $Path" }
  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if (!$line) { return }
    if ($line.StartsWith('#')) { return }
    $idx = $line.IndexOf('=')
    if ($idx -lt 1) { return }
    $k = $line.Substring(0, $idx).Trim()
    $v = $line.Substring($idx + 1).Trim()
    if ($v.StartsWith('"') -and $v.EndsWith('"') -and $v.Length -ge 2) { $v = $v.Substring(1, $v.Length - 2) }
    $map[$k] = $v
  }
  return $map
}

function Ensure-ContainerRunning([string]$Name) {
  $running = docker ps --format "{{.Names}}" | Select-String -SimpleMatch $Name -Quiet
  if (!$running) { throw "Container not running: $Name (run: cd deploy; docker compose up -d)" }
}

function Assert-LastExitCode([string]$Cmd) {
  if ($LASTEXITCODE -ne 0) { throw "$Cmd failed with exit code $LASTEXITCODE" }
}

function Get-OracleDataPumpDir([string]$OracleSysPassword) {
  try {
    $cmd = @"
sqlplus -s sys/$OracleSysPassword@XEPDB1 as sysdba <<'SQL'
set pagesize 0 feedback off verify off heading off echo off
select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
exit;
SQL
"@
    $out = docker exec db-oracle bash -lc $cmd
    $path = ($out | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('SQL>') } | Select-Object -First 1)
    if ($path) { return $path }
  } catch {}
  return "/opt/oracle/admin/XE/dpdump"
}

function Ensure-OracleDataPumpDirAccess([string]$OracleSysPassword, [string]$AppUser, [string]$DirectoryPath) {
  $cmd = @"
sqlplus -s sys/$OracleSysPassword@XEPDB1 as sysdba <<'SQL'
set serveroutput on
declare
  v_count number;
begin
  select count(*) into v_count from dba_directories where directory_name='DATA_PUMP_DIR';
  if v_count = 0 then
    execute immediate 'create directory DATA_PUMP_DIR as ''$DirectoryPath''';
  end if;
  execute immediate 'grant read, write on directory DATA_PUMP_DIR to $AppUser';
end;
/
exit;
SQL
"@
  $null = docker exec db-oracle bash -lc $cmd
  Assert-LastExitCode "grant DATA_PUMP_DIR"
}

Push-Location $PSScriptRoot
try {
  $envMap = Read-DotEnv (Join-Path $PSScriptRoot ".env")
  $src = Resolve-Path $FromDir

  if (!$SkipMySQL) {
    Ensure-ContainerRunning "db-mysql"
    $mysqlRoot = $envMap["MYSQL_ROOT_PASSWORD"]
    if (!$mysqlRoot) { throw "Missing MYSQL_ROOT_PASSWORD in deploy/.env" }
    $mysqlDump = Join-Path $src "mysql.sql"
    if (!(Test-Path $mysqlDump)) { throw "Missing dump file: $mysqlDump" }
    Write-Host "[MySQL] Restoring from $mysqlDump"
    docker cp "$mysqlDump" "db-mysql:/tmp/restore.sql" | Out-Null
    Assert-LastExitCode "docker cp mysql"
    docker exec db-mysql sh -lc "mysql -uroot -p'$mysqlRoot' < /tmp/restore.sql" | Out-Null
    Assert-LastExitCode "mysql restore"
    docker exec db-mysql sh -lc "rm -f /tmp/restore.sql" | Out-Null
    Assert-LastExitCode "rm mysql tmp"
  }

  if (!$SkipPostgres) {
    Ensure-ContainerRunning "db-postgres"
    $pgDb = $envMap["POSTGRES_DB"]
    $pgUser = $envMap["POSTGRES_USER"]
    $pgPass = $envMap["POSTGRES_PASSWORD"]
    if (!$pgDb -or !$pgUser -or !$pgPass) { throw "Missing POSTGRES_DB/POSTGRES_USER/POSTGRES_PASSWORD in deploy/.env" }
    $pgDump = Join-Path $src "postgres.dump"
    if (!(Test-Path $pgDump)) { throw "Missing dump file: $pgDump" }
    Write-Host "[Postgres] Restoring from $pgDump"
    docker cp "$pgDump" "db-postgres:/tmp/restore.dump" | Out-Null
    Assert-LastExitCode "docker cp postgres"
    # Restore into maintenance DB, recreate target DB (-C), and clean existing objects.
    docker exec db-postgres sh -lc "PGPASSWORD='$pgPass' pg_restore -U '$pgUser' -d postgres --clean --if-exists -C /tmp/restore.dump" | Out-Null
    Assert-LastExitCode "pg_restore"
    docker exec db-postgres sh -lc "rm -f /tmp/restore.dump" | Out-Null
    Assert-LastExitCode "rm postgres tmp"
  }

  if (!$SkipOracle) {
    Ensure-ContainerRunning "db-oracle"
    $sysPwd = $envMap["ORACLE_PASSWORD"]
    $appUser = $envMap["ORACLE_APP_USER"]
    $appPwd = $envMap["ORACLE_APP_USER_PASSWORD"]
    if (!$sysPwd -or !$appUser -or !$appPwd) { throw "Missing ORACLE_PASSWORD/ORACLE_APP_USER/ORACLE_APP_USER_PASSWORD in deploy/.env" }

    $oracleDmp = Join-Path $src "oracle.dmp"
    if (!(Test-Path $oracleDmp)) { throw "Missing dump file: $oracleDmp" }
    $dpDir = Get-OracleDataPumpDir $sysPwd
    Ensure-OracleDataPumpDirAccess $sysPwd $appUser $dpDir
    $dumpBase = "dbss_restore"
    Write-Host "[Oracle] Restoring schema $appUser from $oracleDmp"
    docker cp "$oracleDmp" "db-oracle:${dpDir}/${dumpBase}.dmp" | Out-Null
    Assert-LastExitCode "docker cp oracle dmp"
    docker exec db-oracle bash -lc "impdp ${appUser}/${appPwd}@XEPDB1 schemas=${appUser} directory=DATA_PUMP_DIR dumpfile=${dumpBase}.dmp logfile=${dumpBase}.log table_exists_action=replace" | Out-Null
    Assert-LastExitCode "impdp"
  }

  Write-Host "Restore completed from: $src"
}
catch {
  Write-Error $_
  exit 1
}
finally {
  Pop-Location
}
