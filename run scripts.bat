@echo off
 Usage run_script.bat MyTarget.exe TheScriptName.py
set WORK_DIR=Cghidra_work
docker run --rm -v %WORK_DIR%data ghidra-headless ^
    ghidrasupportanalyzeHeadless data tmp_proj ^
    -import data%1 -postScript data%2 -deleteProject