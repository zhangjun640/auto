# Every 30 minutes from 8:00 to 20:00, run one scan
$TaskName = "AutoGreen-Daily"
$ScriptPath = "D:\auto\daily-run.bat"

if (-not (Test-Path $ScriptPath)) {
    Write-Error "Missing $ScriptPath"
    exit 1
}

schtasks /Delete /TN $TaskName /F 2>$null | Out-Null

schtasks /Create /TN $TaskName /TR $ScriptPath /SC DAILY /ST 08:00 /RI 30 /DU 12:00 /F | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create scheduled task"
    exit 1
}

Write-Host "[OK] Task created: $TaskName"
Write-Host "     Scan every 30 min from 8:00 to 20:00"
Write-Host "     Check: taskschd.msc -> $TaskName"
