@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo ============================================================================
    echo Ghidra Headless - Mount Any Folder
    echo ============================================================================
    echo.
    echo Usage: run_headless_custom.bat [SourceFolder] [GhidraArguments...]
    echo.
    echo Example:
    echo   run_headless_custom.bat K:\testlab /data test_proj -import /data -recursive -postScript Find_Base64.py
    echo.
    echo The first argument is the Windows folder to mount.
    echo Everything else is passed directly to Ghidra's analyzeHeadless.
    echo.
    exit /b 1
)

echo ============================================================================
echo Checking for running ghidra-headless containers...
echo ============================================================================

REM Stop any running ghidra-headless containers first
for /f %%i in ('docker ps -q --filter "ancestor=ghidra-headless"') do (
    echo Stopping running container: %%i
    docker stop %%i
)

REM Remove any stopped ghidra-headless containers
for /f %%i in ('docker ps -a -q --filter "ancestor=ghidra-headless"') do (
    echo Removing stopped container: %%i
    docker rm %%i
)

echo.

set "SOURCE_DIR=%~1"
shift

echo ============================================================================
echo Starting Ghidra Headless Analysis...
echo Mounting: %SOURCE_DIR% --^> /data
echo ============================================================================
echo.

REM Collect all remaining arguments
set "ARGS="
:loop
if "%~1"=="" goto :endloop
set "ARGS=!ARGS! %~1"
shift
goto :loop
:endloop

REM Run Docker with automatic cleanup (--rm removes container, not the data)
docker run --rm -v "%SOURCE_DIR%":/data ghidra-headless %ARGS%

REM Store exit code
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo ============================================================================
echo Analysis complete. Container cleaned up.
echo Project files remain in: %SOURCE_DIR%
echo ============================================================================
exit /b %EXIT_CODE%

