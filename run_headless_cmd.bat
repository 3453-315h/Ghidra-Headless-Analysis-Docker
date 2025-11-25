@echo off 
echo Starting Ghidra Headless Analysis... 
echo Mounted: C:\ghidra_work --> /data 
 
:: Usage: run_headless.bat [ProjectName] [ImportFile] [Script] 
:: But defaults to an interactive shell if no args provided 
 
docker run --rm -v "C:\ghidra_work":/data ghidra-headless %* 
