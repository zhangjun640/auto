@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"

if not exist ".git" (
    echo [ERROR] not a git repo
    exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo [ERROR] no remote origin
    exit /b 1
)

echo %date:~0,10% %time%>>CommitTime.txt
git add .
git commit -m "A commit a day keeps the girlfriend away."
if errorlevel 1 (
    echo [WARN] nothing to commit
    exit /b 0
)

git push -u origin master
if not errorlevel 1 goto ok

echo [WARN] push failed, retry with proxy 127.0.0.1:7897>>run.log
git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 push -u origin master
if not errorlevel 1 goto ok

echo [WARN] push failed, retry without proxy>>run.log
git -c http.proxy= -c https.proxy= push -u origin master
if errorlevel 1 (
    echo [ERROR] push failed, check network or GitHub token
    exit /b 1
)

:ok
echo [OK] pushed to GitHub
