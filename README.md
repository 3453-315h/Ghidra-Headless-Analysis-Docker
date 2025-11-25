Ghidra Headless Analysis Server Docker

the default working dir is c:\ghidra_work

you can edit it in the setup, the script will first check if there is a docker container and remove it,
it then sets the working dir, and checks to see if there ghidra.zip in the folder, if not it will download the last release.
it then bulids a docker file, with ubuntu:22.04 & openjdk-21-jdk 
the docker is around 3.35gb in size when complete and spun up.



