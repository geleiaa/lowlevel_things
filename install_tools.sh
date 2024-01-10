#!/bin/bash

##################################################################################################
# Simple script to automate installation of a set of tools for reverse engineering on linux vms
# This script install: build-essential, binutils, git, gcc, gdb and gdb-peda plugin, file, objdump,
# hexdump, xxd, ltrace, strace...
# Create by geleiaa
# Version: 3.0
##################################################################################################

##########################################################################
# Note: gdb, bunutils and build-essential installation error "FATAL Fork"
##########################################################################


tools='file objdump hexdump xxd ltrace strace git python3 pip'

# check if some tools is installed
# later add more tools to check...
is_installed(){

for i in $tools
do
	if test -f /usr/bin/$i
	then
		echo "\n\e[34m $i \e[0m \e[32m IS INSTALLED \e[0m\n"
		sleep 1
	else
		echo "\n \e[34m $i \e[0m \e[31m NOT INSTALLED \e[0m\n"
	        echo "\nINSTALL $i ?? (y/n)\n"
        	read RESP
                	if test $RESP = "y"
	                then
				echo "\n================================="
				echo "INSTALLING \e[34m $i \e[0m..."
				echo "=================================\n"
				sudo apt -y install $i
                	else
                        	echo "\n ...\n"
	                        continue
        	        fi
	fi
done
}


echo "\n================================="
echo "APT UPDATE ..."
echo "=================================\n"

sudo apt update

sleep 2

echo "\n================================="
echo "CHECKING SOME TOOLS ..."
echo "=================================\n"

is_installed

sleep 2

echo "\n================================="
echo "INSTALLING \e[34m build-essential \e[0m..."
echo "=================================\n"

sudo apt -y install build-essential

sleep 2

echo "\n================================="
echo "INSTALLING \e[34m binutils \e[0m..."
echo "=================================\n"


sudo apt -y install binutils

sleep 2

echo "\n================================="
echo "INSTALLING \e[34m gdb \e[0m..."
echo "=================================\n"


sudo apt -y install gdb

sleep 2

echo "\n================================="
echo "INSTALLING \e[34m gdb-peda \e[0m..."
echo "=================================\n"


git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

sleep 2


echo "\n================================="
echo "INSTALLING \e[34m ROPgadget \e[0m..."
echo "=================================\n"


sudo -H python3 -m pip install ROPgadget


echo "\n================================="
echo "\e[32m FINISHED INSTALLATION o/ \e[0m"
echo "=================================\n"
