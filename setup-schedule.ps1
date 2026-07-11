$TaskName = "AutoGreen-Daily"
$XmlPath = "D:\auto\AutoGreen-Daily.xml"

if (-not (Test-Path $XmlPath)) {
    Write-Error "Missing $XmlPath"
    exit 1
}

schtasks /Delete /TN $TaskName /F 2>$null | Out-Null
schtasks /Create /TN $TaskName /XML $XmlPath /F | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create task"
    exit 1
}

Write-Host "[OK] Task created: $TaskName"
Write-Host "     8:00-20:00 every 30 min, battery OK, catch up when PC turns on"
Write-Host "     NOTE: must be logged in (screen lock is OK, but not powered off)"
