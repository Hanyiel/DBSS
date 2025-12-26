param(
  [string]$OutDir = "",
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
  # Query DATA_PUMP_DIR path from the container, fallback to a common default.
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
  $ts = Get-Date -Format "yyyyMMdd-HHmmss"
  $outDir = if ($OutDir) { $OutDir } else { Join-Path $PSScriptRoot "..\\backup\\dumps\\$ts" }
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null

  # Save metadata for reproducibility
  $meta = Join-Path $outDir "meta.txt"
  @(
    "timestamp=$ts"
    "compose_version=$(docker compose version 2>$null)"
    "containers=$(docker ps --format '{{.Names}} {{.Image}} {{.Status}}' | Out-String)"
  ) | Out-File -FilePath $meta -Encoding utf8

  if (!$SkipMySQL) {
    Ensure-ContainerRunning "db-mysql"
    $mysqlRoot = $envMap["MYSQL_ROOT_PASSWORD"]
    $mysqlDb = $envMap["MYSQL_DATABASE"]
    if (!$mysqlRoot -or !$mysqlDb) { throw "Missing MYSQL_ROOT_PASSWORD or MYSQL_DATABASE in deploy/.env" }
    $mysqlDump = Join-Path $outDir "mysql.sql"
    Write-Host "[MySQL] Dumping $mysqlDb -> $mysqlDump"
    docker exec db-mysql sh -lc "mysqldump --default-character-set=utf8mb4 -uroot -p'$mysqlRoot' --databases '$mysqlDb' --routines --triggers --events --single-transaction --add-drop-database --add-drop-table --set-gtid-purged=OFF" `
      | Out-File -FilePath $mysqlDump -Encoding utf8
    Assert-LastExitCode "mysqldump"
  }

  if (!$SkipPostgres) {
    Ensure-ContainerRunning "db-postgres"
    $pgDb = $envMap["POSTGRES_DB"]
    $pgUser = $envMap["POSTGRES_USER"]
    $pgPass = $envMap["POSTGRES_PASSWORD"]
    if (!$pgDb -or !$pgUser -or !$pgPass) { throw "Missing POSTGRES_DB/POSTGRES_USER/POSTGRES_PASSWORD in deploy/.env" }
    $tmp = "/tmp/dbss_$ts.dump"
    $pgDump = Join-Path $outDir "postgres.dump"
    Write-Host "[Postgres] Dumping $pgDb -> $pgDump"
    docker exec db-postgres sh -lc "PGPASSWORD='$pgPass' pg_dump -U '$pgUser' -d '$pgDb' -Fc -f '$tmp'"
    Assert-LastExitCode "pg_dump"
    docker cp "db-postgres:$tmp" "$pgDump" | Out-Null
    Assert-LastExitCode "docker cp postgres"
    docker exec db-postgres sh -lc "rm -f '$tmp'" | Out-Null
    Assert-LastExitCode "rm postgres tmp"
  }

  if (!$SkipOracle) {
    Ensure-ContainerRunning "db-oracle"
    $sysPwd = $envMap["ORACLE_PASSWORD"]
    $appUser = $envMap["ORACLE_APP_USER"]
    $appPwd = $envMap["ORACLE_APP_USER_PASSWORD"]
    if (!$sysPwd -or !$appUser -or !$appPwd) { throw "Missing ORACLE_PASSWORD/ORACLE_APP_USER/ORACLE_APP_USER_PASSWORD in deploy/.env" }

    $dpDir = Get-OracleDataPumpDir $sysPwd
    Ensure-OracleDataPumpDirAccess $sysPwd $appUser $dpDir
    $dumpBase = "dbss_${appUser}_$ts"
    Write-Host "[Oracle] Dumping schema $appUser -> $dumpBase.dmp"
    $expOut = docker exec db-oracle bash -lc "expdp ${appUser}/${appPwd}@XEPDB1 schemas=${appUser} directory=DATA_PUMP_DIR dumpfile=${dumpBase}.dmp logfile=${dumpBase}.log"
    Assert-LastExitCode "expdp"

    $oracleDmp = Join-Path $outDir "oracle.dmp"
    $oracleLog = Join-Path $outDir "oracle.log"

    # expdp may write into a nested GUID folder under dpdump; parse the real path from output when possible.
    $match = $expOut | Select-String -Pattern "/opt/oracle/.+\\.dmp" | Select-Object -Last 1
    $dmpPath = if ($match) { $match.Matches[0].Value.Trim() } else { "${dpDir}/${dumpBase}.dmp" }
    $logPath = ($dmpPath -replace "\.dmp$", ".log").Trim()

    if ($env:DBSS_BACKUP_DEBUG -eq "1") {
      Write-Host "[debug] dmpPath=<$dmpPath> len=$($dmpPath.Length)"
      Write-Host "[debug] logPath=<$logPath> len=$($logPath.Length)"
      Write-Host "[debug] oracleDmp=<$oracleDmp> len=$($oracleDmp.Length)"
      Write-Host "[debug] oracleLog=<$oracleLog> len=$($oracleLog.Length)"
    }

    docker cp "db-oracle:$dmpPath" "$oracleDmp" | Out-Null
    Assert-LastExitCode "docker cp oracle dmp"
    docker cp "db-oracle:$logPath" "$oracleLog" | Out-Null
    Assert-LastExitCode "docker cp oracle log"
  }

  Write-Host "Backup completed: $outDir"
}
catch {
  Write-Error $_
  exit 1
}
finally {
  Pop-Location
}
