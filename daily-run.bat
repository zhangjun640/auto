@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo [%date% %time%] ===== 今日任务开始（8:00-20:00 内多次随机提交）=====>>run.log

:loop
for /f %%i in ('powershell -NoProfile -Command ^
  "$now=Get-Date; $deadline=$now.Date.AddHours(20); ^
   if($now -ge $deadline){ Write-Output -1; exit }; ^
   $maxDelay=[Math]::Min(300,[Math]::Floor(($deadline-$now).TotalMinutes)); ^
   Write-Output (Get-Random -Minimum 0 -Maximum ($maxDelay+1))"') do set delay_minutes=%%i

if "!delay_minutes!"=="-1" goto end

set /a delay_seconds=delay_minutes * 60
echo [%date% %time%] 下次提交：%delay_minutes% 分钟后>>run.log
timeout /t !delay_seconds! /nobreak >nul

powershell -NoProfile -Command "if((Get-Date) -ge (Get-Date).Date.AddHours(20)){ exit 1 } else { exit 0 }"
if errorlevel 1 goto end

call "%~dp0auto-commit.bat" >>run.log 2>&1
goto loop

:end
echo [%date% %time%] ===== 今日任务结束 =====>>run.log
