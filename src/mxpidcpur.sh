#!/bin/bash

#  mxpidcpur.sh
#  MxPidCpuRange
#
#  Created by BitesPotatoBacks on 6/24/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

if [[ $(arch) != "arm64" ]]; then
    echo "${BOLD}$PROG: ${RED}error:${NF} arch $(arch) unsupported"
    exit 1
fi

#
# Variables
#
PROG="mxpidcpur"
VER="v0.1.0"

PCPUS=$(sysctl hw.perflevel0.logicalcpu | awk '{print $2}')
ECPUS=$(sysctl hw.perflevel1.logicalcpu | awk '{print $2}')
CPUS=$(sysctl hw.logicalcpu | awk '{print $2}')

PS_FILE="/Library/Caches/mxpidcpur/ps_out.txt"

BOLD=$(tput bold)
RED=$(tput setaf 1)
NF=$(tput sgr0)

#
# Checking args
#
INTERVAL=56
SHOULD_USE_RES=true

while getopts "i:uhvV" OPT; do
    case $OPT in
        i)   INTERVAL=$OPTARG ;;
        u)   SHOULD_USE_RES=false ;;
        v|V) echo "$PROG $VER"; exit ;;
        h|*) echo "usage: $PROG -h | -V";
             echo "usage: $PROG -u [-i interval] pid[,pid...]";
             echo "Options:";
             echo "   -h     print help and exit";
             echo "   -V     print version and exit";
             echo "   -i<N>  sampling interval for core residency (higher is better) [default:56ms]";
             echo "   -u     disable the use of core residency to narrow the affinity list(s)";
             exit ;;
    esac
done

shift $(($OPTIND - 1))

#
# pulling our pids
#
PIDS=$1

if [[ ! "$PIDS" ]] || [[ $# -gt 1 ]]; then
    echo "${BOLD}$PROG: ${RED}error:${NF} incorrect number of args (recieved $# items)"
    exit 1
fi


PS=$(ps -p $PIDS -o pri= -o pid= > $PS_FILE)

PS_PRI=$(awk '{print $1}' $PS_FILE)
PS_PID=$(awk '{print $2}' $PS_FILE)

PS_PRI=($PS_PRI)
PS_PID=($PS_PID)

#
# loop through all pids and display metrics
#
for (( i = 0; i < ${#PS_PID[@]}; i++)); do

    PRI=$(echo ${PS_PRI[$i]})
    PID=$(echo ${PS_PID[$i]})
    
    QOS=""
    AFFINITY=0
    
    #
    # determine QoS
    #
    if [[ $PRI == 4 ]]; then
        QOS="Background"
    elif [[ $PRI == 20 ]]; then
        QOS="Utility"
    elif [[ $PRI == 31 ]]; then
        QOS="User Initiated/Interactive"
    else
        QOS="Default"
    fi
    
    #
    # find dirty cpu range based on qos
    #
    if [[ $PRI -lt 4 ]] || [[ $PRI == 4 ]]; then
        AFFINITY=ECPUS
    else
        AFFINITY=CPUS
    fi
    
    echo "PID $PID"
    printf "  Available Hosting Cores:  "
    
    # print affinity list with improved range based on core residency metrics (assuming they are enabled)
    for (( ii = 0; ii < $CPUS; ii++ )); do
    
        LABEL="ECPU"
        CURRENT_CORE=$ii
        
        if [[ $CURRENT_CORE -gt $(($ECPUS - 1)) ]]; then
            LABEL="PCPU"
            CURRENT_CORE=$(($ii - $PCPUS))
        fi
        
        if [[ $ii -lt AFFINITY ]];
        then
            if [[ $SHOULD_USE_RES == true ]]; then
                USAGE=$(mxpidcpur_cpures $INTERVAL $CPUS $ii)
            else
                USAGE="100"
            fi
            
            if [[ $USAGE != "0.00" ]]; then
                printf "${BOLD}${LABEL}$CURRENT_CORE ${NF}"
            else
                printf "\033[90m${LABEL}$CURRENT_CORE ${NF}"
            fi
        else
            printf "\033[90m${LABEL}$CURRENT_CORE ${NF}"
        fi
        
    done
    
    # print QoS
    printf "\n  Quality of Service:       $QOS\n\n"
done

