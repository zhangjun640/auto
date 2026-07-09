# 每天 8:00 启动 daily-run.bat，脚本内随机延迟 0-720 分钟，在 8:00-20:00 之间提交
$TaskName = "AutoGreen-Daily"
$ScriptPath = "D:\auto\daily-run.bat"
$WorkingDir = "D:\auto"

if (-not (Test-Path $ScriptPath)) {
    Write-Error "找不到 $ScriptPath"
    exit 1
}

$Action = New-ScheduledTaskAction -Execute $ScriptPath -WorkingDirectory $WorkingDir
$Trigger = New-ScheduledTaskTrigger -Daily -At "08:00"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null

Write-Host "[OK] 计划任务已创建: $TaskName"
Write-Host "     每天 8:00 启动，随机在 8:00-20:00 之间提交到 GitHub"
Write-Host "     查看任务: taskschd.msc -> 任务计划程序库 -> $TaskName"
