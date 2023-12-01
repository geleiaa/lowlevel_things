#!/bin/bash

###############################################################################################
# Simple script to automate installation of a set of tools for reverse engineering on linux vms
# This script install: build-essential, binutils, gcc, gdb and peda plugin ...
# Create by geleiaa
###############################################################################################


echo "\n#################################"
echo "INSTALLING gdb ..."
echo "#################################\n"

sudo apt -y install gdb


echo "\n#################################"
echo "INSTALLING gdb-peda ..."
echo "#################################\n"

git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"


echo "\n#################################"
echo "INSTALLING gcc ..."
echo "#################################\n"

sudo apt -y install gcc


echo "\n#################################"
echo "INSTALLING binutils ..."
echo "#################################\n"

sudo apt -y install binutils


echo "\n#################################"
echo "INSTALLING build-essential ..."
echo "#################################\n"

sudo apt -y install build-essential


echo "\n#################################"
echo "FINISHED INSTALLATION o/"
echo "#################################\n"
