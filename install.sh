#!/bin/sh

#  mxpidaffg.sh
#  MxPidQosBuddy
#
#  Created by BitesPotatoBacks on 6/24/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

PROG="mxpidqosbud"
VER="v0.2.0"

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
        
    echo " [1/3] Checking PATH"

    if echo $PATH | grep -q "usr/local/bin"; then :; else
        printf "\n\nexport PATH=\"/usr/local/bin:\$PATH\"" >> ~/.zshrc
    fi
    
    echo " [2/3] Preparing scripts"
    chmod 755 $DIR/mxpidqosbud.sh
    cp $DIR/mxpidqosbud.sh $DIR/mxpidqosbud
    xattr -cr $DIR/mxpidqosbud_cpures

    echo " [3/3] Putting things where they need to be"
    sudo mv $DIR/mxpidqosbud /usr/local/bin/mxpidqosbud
    sudo cp $DIR/mxpidqosbud_cpures /usr/local/bin/mxpidqosbud_cpures
    
    echo "${GREEN}Install Complete!${NF}"
}

uninstall() {
    check_sudo
    sudo rm -rf /usr/local/bin/mxpidqosbud
    sudo rm -rf /usr/local/bin/mxpidqosbud_cpures
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

[[ $(arch) != "arm64" ]] && echo "${BOLD}$PROG: ${RED}error:${NF} arch unsupported" && exit 1;

while getopts "uirhvV" OPT; do
    case $OPT in
        u) uninstall 2> /dev/null;
           echo "${PURPLE}Uninstalled $PROG ($VER)${NF}";
           exit ;;
        i) echo "${BOLD}Installing $PROG ($VER) ${NF}";
           install 2> /dev/null;
           exit ;;
        r) echo "${BOLD}Reinstalling $PROG ($VER)${NF}";
           uninstall 2> /dev/null;
           echo "${PURPLE}Uninstalled previous version${NF}"
           install 2> /dev/null;
           exit ;;
        v|V) echo "${BOLD}Installing:${NF} $PROG ($VER)" ;;
        h|*) usage;;
    esac
done

[[ $# -eq 0 ]] && usage
