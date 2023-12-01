#!/bin/bash

##################################################################################################
# Simple script to automate installation of a set of tools for reverse engineering on linux vms
# This script install: build-essential, binutils, gcc, gdb and gdb-peda plugin...
# and if not installed: file, objdump, hexdump, xxd, ltrace, strace...
# Create by geleiaa
# Version: 2.0
##################################################################################################


tools='file objdump hexdump xxd ltrace strace'

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

echo "\n================================="
echo "CHECKING SOME TOOLS ..."
echo "=================================\n"

is_installed


echo "\n================================="
echo "INSTALLING \e[34m gdb \e[0m..."
echo "=================================\n"

sudo apt -y install gdb


echo "\n================================="
echo "INSTALLING \e[34m git \e[0m..."
echo "=================================\n"

sudo apt -y install git


echo "\n================================="
echo "INSTALLING \e[34m gdb-peda \e[0m..."
echo "=================================\n"

git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"


echo "\n================================="
echo "INSTALLING \e[34m gcc \e[0m..."
echo "=================================\n"

sudo apt -y install gcc


echo "\n================================="
echo "INSTALLING \e[34m binutils \e[0m..."
echo "=================================\n"

sudo apt -y install binutils


echo "\n================================="
echo "INSTALLING \e[34m build-essential \e[0m..."
echo "=================================\n"

sudo apt -y install build-essential


echo "\n================================="
echo "\e[32mFINISHED INSTALLATION o/\e[0m"
echo "=================================\n"
