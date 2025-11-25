Ghidra Headless Analysis Server Docker 24/11/25

the default working dir is c:\ghidra_work

you can edit it in the setup, the script will first check if there is a docker container and remove it,
it then sets the working dir, and checks to see if there ghidra.zip in the folder, if not it will download the last release.
it then bulids a docker file, with ubuntu:22.04 & openjdk-21-jdk 
the docker is around 3.35gb in size when complete and spun up.

run setup.bat it will build the docker.

so there are two ways to work with this
you can dump exe, etc into the work dir and then
run_headless.bat
run_headless.bat /data tmp_proj -import /data/Mrt.exe -scriptPath /data -postScript Find_Base64.py


the run_headless_custom.bat allows you to mount a dir so you can include the exe and its dlls.
run_headless_custom.bat K:\testlab /data test -import /data/test.exe -scriptPath /data/sag -postScript 01_TaintAnalysis.py -postScript 05_BatchReportGenerator.py

(note it will dismount the image, and remount it with the custom dir you target)

to automate multiple scripts look at the run scripts.bat there is the logic to do just that or u can just  -postScript to run_headless_custom.bat 


    Workflow_Orchestrator.py
    # Usage: -postScript Workflow_Orchestrator.py
    # Reads 'pipeline.txt' and executes scripts in order
    import os

    CONFIG_FILE = "/data/pipeline.txt" # List of script names, one per line

    if os.path.exists(CONFIG_FILE):
    with open(CONFIG_FILE, "r") as f:
        scripts = f.readlines()
    
    for script in scripts:
        script = script.strip()
        if script and not script.startswith("#"):
            print(">>> [ORCHESTRATOR] Running: " + script)
            # In Ghidra Headless, we can simply call the runScript helper if available, 
            # or we simulate it by importing the module (complex in Jython).
            # Easier method: Print instructions for the Batch file to loop.
            print("    (Script chaining logic would go here)")
    else:
    print(">>> No pipeline config found.")


   then u place your scripts in pipeline.txt for the workflow your aimming for.
