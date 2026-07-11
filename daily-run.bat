@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo [%date% %time%] task triggered>>run.log
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0daily-run.ps1"
