@echo off
setlocal enabledelayedexpansion

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


echo Starting Ghidra Headless Analysis... 
echo Mounted: C:\ghidra_work --> /data 
docker run --rm -v "C:\ghidra_work":/data ghidra-headless %* 
