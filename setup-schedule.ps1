# 每天 8:00 启动，8:00-20:00 内循环随机提交（每次间隔 0-300 分钟）
$TaskName = "AutoGreen-Daily"
$ScriptPath = "D:\auto\daily-run.bat"
$WorkingDir = "D:\auto"

if (-not (Test-Path $ScriptPath)) {
    Write-Error "找不到 $ScriptPath"
    exit 1
}

$Action = New-ScheduledTaskAction -Execute $ScriptPath -WorkingDirectory $WorkingDir
$Trigger = New-ScheduledTaskTrigger -Daily -At "08:00"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 14)

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null

Write-Host "[OK] 计划任务已创建: $TaskName"
Write-Host "     每天 8:00 启动，8:00-20:00 内多次提交，每次随机间隔 0-300 分钟"
Write-Host "     查看任务: taskschd.msc -> 任务计划程序库 -> $TaskName"
