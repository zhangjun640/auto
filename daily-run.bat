@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"

rem 8:00 启动后随机等待 0-720 分钟，在 8:00-20:00 之间提交
set /a delay_minutes=%RANDOM% %% 721
set /a delay_seconds=delay_minutes * 60

echo [%date% %time%] 将在 %delay_minutes% 分钟后提交（约 8:00-20:00 之间随机）>>run.log
timeout /t %delay_seconds% /nobreak >nul

call "%~dp0auto-commit.bat" >>run.log 2>&1
