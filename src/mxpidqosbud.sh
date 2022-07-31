#!/bin/bash

#  mxpidqosbud.sh
#  MxPidQosBuddy
#
#  Created by BitesPotatoBacks on 6/24/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

PROG="mxpidqosbud"
VER="v0.2.0"
BUILD="Jul 28 2022"

PCPUS=$(sysctl hw.perflevel0.logicalcpu | awk '{print $2}')
ECPUS=$(sysctl hw.perflevel1.logicalcpu | awk '{print $2}')
CPUS=$(sysctl hw.logicalcpu | awk '{print $2}')

BOLD=$(tput bold)
RED=$(tput setaf 1)
NF=$(tput sgr0)

INTERVAL=64
SHOULD_USE_RES=true
SHOULD_USE_GID=false

[[ $(arch) != "arm64" ]] && echo "${BOLD}$PROG: ${RED}error:${NF} arch unsupported" && exit 1;

while getopts "i:guhvV" OPT; do
    case $OPT in
        i)   INTERVAL=$OPTARG ;;
        g)   SHOULD_USE_GID=true ;;
        u)   SHOULD_USE_RES=false ;;
        v|V) echo "$PROG $VER (build $BUILD)";
             exit ;;
        h|*) echo "usage: $PROG -h | -V";
             echo "usage: $PROG -gu [-i interval] pid[,pid...]";
             echo "Options:";
             echo "   -h      print help and exit";
             echo "   -V      print version and exit";
             echo "   -i<N>   sampling interval for core residency (higher is better) [default:64ms]";
             echo "   -g      expect gids rather than pids and return metrics accordingly";
             echo "   -u      disable the use of core residency to narrow the CPU core range(s)";
             exit ;;
    esac
done

shift $(($OPTIND - 1))

if [[ ! "$1" ]] || [[ $# -gt 1 ]]; then
    echo "${BOLD}$PROG: ${RED}error:${NF} incorrect number of args (recieved $# items)"
    exit 1
fi

# Accessing our data from ps command
if [[ $SHOULD_USE_GID == false ]]; then
    PS="ps -p $1 -o pri= -o pid= -o %cpu"
else
    PS="ps -G $1 -o pri= -o pid= -o %cpu"
fi

PS_PRI=($(command $PS | awk '{print $1}'))
PS_PID=($(command $PS | awk '{print $2}'))
PS_USE=($(command $PS | awk '{print $2}'))

# loop through all pids and display metrics
for (( i = 0; i < ${#PS_PID[@]}; i++)); do
    PRI=$(echo ${PS_PRI[$i]})
    PID=$(echo ${PS_PID[$i]})
    PIDUSE=$(echo ${PS_USE[$i]})
    
    QOS="Default"
    AFFINITY=CPUS
    
    # determine QoS
    case $PRI in
        4)  QOS="Background";
            AFFINITY=ECPUS ;; # reflect affinity of QoS 9
        20) QOS="Utility" ;;
        31) QOS="User Initiated/Interactive" ;;
    esac

    basename -- "$(ps -p $PID -o comm=)" | tr -d '\n'; printf " ($PID)\n  Available Hosting Cores:  "
    
    # print affinity list narrowed based on core residency metrics (assuming they are enabled)
    for (( ii = 0; ii < $CPUS; ii++ )); do
        USAGE="100"
        LABEL="ECPU"
        CURRENT_CORE=$ii
        OUTPUT="\033[90m${LABEL}$CURRENT_CORE"
        
        if [[ $CURRENT_CORE -gt $(($ECPUS - 1)) ]]; then
            LABEL="PCPU"
            CURRENT_CORE=$(($ii - $PCPUS))
        fi
        
        if [[ $ii -lt AFFINITY ]]; then
            [[ $SHOULD_USE_RES == true ]] && USAGE=$(./mxpidqosbud_cpures $INTERVAL $CPUS $ii)
            [[ $USAGE != "0.00" ]]        && OUTPUT="${BOLD}${LABEL}$CURRENT_CORE"
        fi
        
        printf "$OUTPUT $NF"
    done
    
    printf "\n  Quality of Service:       $QOS\n\n"
done
