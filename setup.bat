@echo off
setlocal

:: ============================================================================
:: CONFIGURATION
:: ============================================================================
set "WORK_DIR=C:\ghidra_work"
set "DOCKER_TAG=ghidra-headless"

echo ============================================================================
echo      GHIDRA HEADLESS SETUP (JDK 21 EDITION)
echo ============================================================================
echo.

:: 1. CHECK FOR DOCKER
echo [1/5] Checking for Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not running.
    pause
    exit /b 1
)

:: 2. SETUP WORK DIRECTORY
echo [2/5] Setting up %WORK_DIR%...
if not exist "%WORK_DIR%" (
    mkdir "%WORK_DIR%"
)
cd /d "%WORK_DIR%"

:: 3. DOWNLOAD GHIDRA
if exist "ghidra.zip" (
    echo [3/5] Found existing ghidra.zip, skipping download...
) else (
    echo [3/5] Downloading Ghidra...
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; $latest = Invoke-RestMethod -Uri 'https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest'; $url = $latest.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1 -ExpandProperty browser_download_url; Invoke-WebRequest -Uri $url -OutFile 'ghidra.zip'"
)

:: 4. GENERATE DOCKERFILE (JDK 21)
echo [4/5] Generating Dockerfile...
if exist Dockerfile del Dockerfile

echo FROM ubuntu:22.04 > Dockerfile
echo ENV DEBIAN_FRONTEND=noninteractive >> Dockerfile
echo RUN apt-get update ^&^& apt-get install -y openjdk-21-jdk unzip wget procps git ^&^& rm -rf /var/lib/apt/lists/* >> Dockerfile
echo WORKDIR /app >> Dockerfile
echo COPY ghidra.zip . >> Dockerfile
echo RUN unzip ghidra.zip ^&^& rm ghidra.zip ^&^& mv ghidra_* ghidra >> Dockerfile
echo RUN chmod +x /app/ghidra/support/*.sh >> Dockerfile
echo RUN chmod +x /app/ghidra/support/analyzeHeadless >> Dockerfile
echo WORKDIR /data >> Dockerfile
echo ENV PATH="/app/ghidra/support:${PATH}" >> Dockerfile
echo ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64" >> Dockerfile
echo ENTRYPOINT ["/app/ghidra/support/analyzeHeadless"] >> Dockerfile

:: 5. BUILD DOCKER IMAGE
echo [5/5] Building Docker Image...
docker build -t %DOCKER_TAG% .

if %errorlevel% neq 0 (
    echo [ERROR] Docker build failed.
    pause
    exit /b 1
)

:: 6. CREATE LAUNCHER
echo Creating run_headless.bat...
echo @echo off > run_headless.bat
echo echo Starting Ghidra Headless Analysis... >> run_headless.bat
echo echo Mounted: %WORK_DIR% --^> /data >> run_headless.bat
echo docker run --rm -v "%WORK_DIR%":/data %DOCKER_TAG% %%* >> run_headless.bat

echo.
echo ============================================================================
echo      SETUP COMPLETE!
echo ============================================================================
echo.
echo Run Ghidra Headless using:
echo    run_headless.bat [ProjectDir] [ProjectName] -import [File] [Args...]
echo.
pause
