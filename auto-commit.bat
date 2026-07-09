@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"

if not exist ".git" (
    echo [ERROR] 当前目录不是 Git 仓库，请先在 D:\auto 执行 git init
    exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未配置 GitHub 远程仓库，请先运行 setup-remote.bat
    exit /b 1
)

echo %date:~0,10% %time%>>CommitTime.txt
git add .
git commit -m "A commit a day keeps the girlfriend away."
git push -u origin master

if errorlevel 1 (
    echo [ERROR] 提交或推送失败，请检查网络和 GitHub 认证
    exit /b 1
)

echo [OK] 已提交并推送到 GitHub
