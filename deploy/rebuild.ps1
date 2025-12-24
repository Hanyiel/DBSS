Set-StrictMode -Version Latest

Write-Host "This will STOP containers and DELETE local DB volumes under ..\\data\\{mysql,postgres,oracle}."
Write-Host "Press Ctrl+C to cancel."
Start-Sleep -Seconds 3

Push-Location $PSScriptRoot
try {
  docker compose down

  $paths = @("..\\data\\mysql", "..\\data\\postgres", "..\\data\\oracle")
  foreach ($p in $paths) {
    if (Test-Path $p) {
      Remove-Item -Recurse -Force $p
    }
    New-Item -ItemType Directory -Force -Path $p | Out-Null
  }

  docker compose up -d
}
finally {
  Pop-Location
}

