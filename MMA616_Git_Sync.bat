@echo off
setlocal enabledelayedexpansion

REM ================================
REM MMA 616 GitHub Sync Script
REM Repo: https://github.com/Ancient9528Potato/mma616-group-ai-dashboard
REM What it does:
REM 1. Clones the repo to Desktop if it does not exist
REM 2. Pulls the latest version from GitHub
REM 3. If you changed files, commits them
REM 4. Pushes your changes back to GitHub
REM ================================

set "REPO_URL=https://github.com/Ancient9528Potato/mma616-group-ai-dashboard.git"
set "REPO_DIR=%USERPROFILE%\Desktop\mma616-group-ai-dashboard"
set "BRANCH=main"

echo.
echo ==========================================
echo    MMA 616 GitHub Sync Script
echo ==========================================
echo.

REM Check Git installation
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not available in PATH.
    echo Please install Git from https://git-scm.com/downloads and try again.
    echo.
    pause
    exit /b 1
)

REM Clone repo if missing
if not exist "%REPO_DIR%\.git" (
    echo Repo folder not found on Desktop.
    echo Cloning from GitHub...
    echo.
    cd /d "%USERPROFILE%\Desktop"
    git clone "%REPO_URL%"
    if errorlevel 1 (
        echo.
        echo ERROR: Clone failed. Check the repo URL, internet connection, and GitHub access.
        pause
        exit /b 1
    )
)

cd /d "%REPO_DIR%"
if errorlevel 1 (
    echo ERROR: Could not open repo folder: %REPO_DIR%
    pause
    exit /b 1
)

echo Working folder:
echo %REPO_DIR%
echo.

REM Make sure remote URL is correct
git remote set-url origin "%REPO_URL%" >nul 2>&1

echo Pulling latest changes from GitHub...
git pull origin %BRANCH%
if errorlevel 1 (
    echo.
    echo ERROR: Pull failed. You may have a merge conflict or authentication issue.
    echo Open the folder in VS Code, resolve conflicts, then run this script again.
    pause
    exit /b 1
)

echo.
echo Checking for local changes...
git status --porcelain > "%TEMP%\mma616_git_status.txt"
for %%A in ("%TEMP%\mma616_git_status.txt") do set STATUS_SIZE=%%~zA

if "%STATUS_SIZE%"=="0" (
    echo No local changes to commit.
    echo Your repo is up to date.
    echo.
    pause
    exit /b 0
)

echo.
echo Local changes found:
git status --short
echo.
set /p COMMIT_MSG="Enter commit message, or press Enter for automatic message: "
if "%COMMIT_MSG%"=="" (
    set "COMMIT_MSG=Update project files - %DATE% %TIME%"
)

echo.
echo Adding files...
git add -A

echo Committing changes...
git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
    echo.
    echo ERROR: Commit failed. There may be nothing to commit or Git may need your name/email configured.
    echo To configure Git, run:
    echo git config --global user.name "Your Name"
    echo git config --global user.email "your-email@example.com"
    pause
    exit /b 1
)

echo.
echo Pulling again with rebase before push...
git pull --rebase origin %BRANCH%
if errorlevel 1 (
    echo.
    echo ERROR: Rebase failed. A teammate may have changed the same file.
    echo Open the folder in VS Code, resolve conflicts, then run:
    echo git rebase --continue
    echo Then run this script again.
    pause
    exit /b 1
)

echo.
echo Pushing to GitHub...
git push origin %BRANCH%
if errorlevel 1 (
    echo.
    echo ERROR: Push failed. Check your GitHub login/permission and internet connection.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Success! Your project is synced with GitHub.
echo ==========================================
echo.
pause
