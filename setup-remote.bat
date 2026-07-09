@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"

echo 请先在 GitHub 新建一个空仓库（不要勾选 README），然后输入仓库地址。
echo 示例: https://github.com/zhangjun640/auto-green.git
echo.

set /p REPO_URL=GitHub 仓库地址: 

if "%REPO_URL%"=="" (
    echo [ERROR] 地址不能为空
    exit /b 1
)

git remote remove origin >nul 2>&1
git remote add origin "%REPO_URL%"

echo.
echo [OK] 远程仓库已设置为:
git remote -v

echo.
echo 首次推送请运行: auto-commit.bat
