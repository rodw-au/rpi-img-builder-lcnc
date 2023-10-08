#!/bin/bash

set -e

# Ensuring we have all the tools we require

missing=""
for tool in git curl apt wget make
do
	if command -v "$tool" > /dev/null ; then
		missing="$missing $tool"
	fi
done
if [ -n "$missing" ]; then
	echo "E: This script lacks the following tool(s) to be executed successfully: $missing"
	echo "I: To update your current installation and install all build deps run"
	echo "   sudo apt update
	echo "   sudo apt upgrade -y
	echo "   sudo apt install -y git curl wget make"
	exit 1
fi

# Loading helping routines

source lib/source

# Main

RED="\e[0;31m"
GRN="\e[0;32m"
PNK="\e[0;35m"
TXT="\033[0m"
YLW="\e[0;33m"
FIN="\e[0m"

GIT_BRANCH=$(git branch)

echo
echo -en "${TXT}Raspberry Pi Image Builder:${FIN}"
echo -e " ${PNK}[${FIN}${GRN}${GIT_BRANCH}${FIN}${PNK}]${FIN}"

echo -en "${TXT}Checking Internet Connection:${FIN} "
if curl -I https://github.com 2>&1 | grep -q 'HTTP/2 200' ; then
	echo -en "${PNK}[${FIN}${GRN}OK${FIN}${PNK}]${FIN}"
	echo
else
	echo -en "${PNK}[${FIN}${RED}failed${FIN}${PNK}]${FIN}"
	echo
	echo -e "${TXT}Please check your internet connection and try again${FIN}."
	exit 1
fi
echo -en "${TXT}Checking Host Machine:${FIN} "
sleep .50
if [[ "$HOST_CODENAME" == "jammy" ]]; then
	echo -en "${PNK}[${FIN}${GRN}Ubuntu Jammy Jellyfish${FIN}${PNK}]${FIN}"
	echo
else
	if [[ "$HOST_CODENAME" == "bullseye" ]]; then
		echo -en "${PNK}[${FIN}${GRN}Debian Bullseye${FIN}${PNK}]${FIN}"
		echo
	else
		if [[ "$HOST_CODENAME" == "bookworm" ]]; then
			echo -en "${PNK}[${FIN}${GRN}Debian Bookworm${FIN}${PNK}]${FIN}"
			echo
		else
			echo -ne "${PNK}[${FIN}${RED}failed${FIN}${PNK}]${FIN}"
			echo
			echo -e "${TXT}The OS you are running is not supported${FIN}."
			exit 1
		fi
	fi
fi
echo
if [[ "$HOST_ARCH" == "x86_64" || "$HOST_ARCH" == "aarch64" ]]; then
	:;
else
	echo -e "ARCH: $HOST_ARCH is not supported by this script."
	exit 1
fi

if [[ "$HOST_ARCH" == "x86_64" ]]; then
	echo -e "${TXT}Starting install ...${FIN}"
	sleep .50
	make ccompile
fi

if [[ "$HOST_ARCH" == "aarch64" ]]; then
	echo -e -n "${TXT}"
	echo -e "Arm64 detected. Select the dependencies you would like installed."
	options=("Cross Compiling" "Native Compiling" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Cross Compiling")
				make ccompile64
				break
				;;
			"Native Compiling")
				make ncompile
				break
				;;
			"Quit")
				break
				;;
			*)
				echo "invalid option $REPLY"
				;;
		esac
	done
	echo -e -n "${FIN}"
fi

# install builder theme
make dialogrc

# clear
clear -x

# builder options
make help

exit 0
