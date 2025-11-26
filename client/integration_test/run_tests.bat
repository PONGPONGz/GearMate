@echo off
REM GearMate Automated Test Runner for Windows
REM This script runs integration tests similar to Selenium for web

echo ======================================
echo GearMate Automated Integration Tests
echo ======================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo Flutter detected
flutter --version | findstr /C:"Flutter"
echo.

REM Navigate to client directory (parent of integration_test)
cd /d "%~dp0.."

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo Error: pubspec.yaml not found. Are you in the right directory?
    exit /b 1
)

echo Installing dependencies...
call flutter pub get
echo.

REM Check for connected devices/emulators
echo Checking for available devices...
flutter devices
echo.

echo ======================================
echo Running Integration Tests
echo ======================================
echo.

REM Check for test file in integration_test folder (Flutter standard)
if exist "integration_test\sorting_gear_test.dart" (
    echo Running: integration_test\sorting_gear_test.dart
    echo.
    call flutter test integration_test\sorting_gear_test.dart
    
    if %errorlevel% equ 0 (
        echo.
        echo ======================================
        echo All tests PASSED!
        echo ======================================
    ) else (
        echo.
        echo ======================================
        echo Some tests FAILED
        echo ======================================
        exit /b 1
    )
) else (
    echo Error: Test file not found!
    exit /b 1
)
