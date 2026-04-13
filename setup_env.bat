@echo off
TITLE SmartCampus Development Environment Setup

echo ==========================================
echo SmartCampus Development Environment Setup
echo ==========================================

echo This script will help you set up your Windows development environment.

echo.
echo [1] Automated Setup (Recommended)
echo     This will open the Flutter Setup tool which automates the installation of:
echo     - Flutter SDK
echo     - Android SDK
echo     - Android Studio
echo     - VSCode
echo     - Git
echo.
echo [2] Manual Setup Links
echo.

set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo Opening Flutter Setup Tool download page...
    echo Please download and run the installer from the page that opens.
    start https://flutter-setup.dev/download/1/25?os=Windows
    
    echo.
    echo Once the tool finishes, your environment should be ready!
    pause
    exit
)

if "%choice%"=="2" (
    echo.
    echo Please visit the following links to install tools manually:
    echo Flutter: https://docs.flutter.dev/get-started/install/windows
    echo VSCode: https://code.visualstudio.com/
    echo Git: https://git-scm.com/download/win
    pause
    exit
)

echo Invalid choice.
pause
