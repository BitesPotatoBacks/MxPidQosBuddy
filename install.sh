#!/bin/sh

#  mxpidaffg.sh
#  MxPidCpuRange
#
#  Created by BitesPotatoBacks on 6/24/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

if [[ $(arch) != "arm64" ]]; then
    echo "${BOLD}$PROG: ${RED}error:${NF} arch $(arch) unsupported"
    exit 1
fi

PROG="mxpidcpur"
VER="v0.1.0"

LIB="/Library/Caches/mxpidcpur"
DIR="$(dirname "${BASH_SOURCE[0]}")/src"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)

BOLD=$(tput bold)
NF=$(tput sgr0)

check_sudo() {
    if [ $UID -ne 0 ]; then
        echo "root is required to install/uninstall $PROG, please authenticate"
        exit 1
    fi
}

install() {
    check_sudo
    
    echo " [1/3] Generating files"
    mkdir $LIB
    touch ${LIB}/ps_out.txt
    
    sudo chmod 4777 $LIB
    sudo chmod 4777 ${LIB}/ps_out.txt
        
    echo " [2/3] Placing shell script"
    
    if echo $PATH | grep -q "usr/local/bin"; then
        :
    else
        export PATH=$PATH:/usr/local/bin
    fi
    
    chmod 755 $DIR/mxpidcpur.sh
    cp $DIR/mxpidcpur.sh $DIR/mxpidcpur
    sudo mv $DIR/mxpidcpur /usr/local/bin/mxpidcpur
    
    echo " [3/3] Placing helper binary"
    
    xattr -cr $DIR/mxpidcpur_cpures
    sudo cp $DIR/mxpidcpur_cpures /usr/local/bin/mxpidcpur_cpures
    
    echo "${GREEN}Install Complete!${NF}"
}

uninstall() {
#    if [ ! -f "${LIB}/ps_out.txt" ]; then
#        echo "${RED}Uninstall Failed:${NF} Not previously installed ";
#        exit 1
#    fi
    
    check_sudo
    
    echo " [1/3] Removing files"
    sudo rmdir $LIB
    sudo rm -rf $PS_FILE
    
    echo " [2/3] Removing shell script"
    sudo rm -rf /usr/local/bin/mxpidcpur
    
    echo " [2/3] Removing helper binary"
    sudo rm -rf /usr/local/bin/mxpidcpur_cpures
    
    echo "${PURPLE}Uninstall Complete!${NF}"
}

usage() {
    echo "usage: install.sh -h | -V"
    echo "usage: install.sh [-i|-u|-r]"
    echo "Options: "
    echo "   -h   print help and exit"
    echo "   -V   print install version and exit"
    echo "   -i   install $PROG"
    echo "   -u   uninstall $PROG"
    echo "   -r   reinstall $PROG"
    exit
}


while getopts "uirhV" OPT; do
    case $OPT in
        u) echo "${BOLD}Uninstalling $PROG ($VER)${NF}"; uninstall 2> /dev/null; exit ;;
        i) echo "${BOLD}Installing $PROG ($VER) ${NF}"; install 2> /dev/null; exit ;;
        r) echo "${BOLD}Reinstalling $PROG ($VER)${NF}"; uninstall 2>  /dev/null; install 2>  /dev/null; exit;;
        V) echo "${BOLD}Installing:${NF} $PROG ($VER)" ;;
        h|*) usage;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi
