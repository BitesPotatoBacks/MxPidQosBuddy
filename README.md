<h1 align="center" style="">MxPidCpuRange</h1>
<p align="center">
  A simple shell script to find the QoS and determine the range of CPU cores available to the specifed PID(s) (for Apple M-Series)
</p>

<p align="center">
    <a href="">
       <img alt="MacOS" src="https://img.shields.io/badge/MacOS-arm64-red.svg"/>
    </a>
    <a href="https://github.com/BitesPotatoBacks/MxPidCpuRange/releases">
        <img alt="Releases" src="https://img.shields.io/github/release/BitesPotatoBacks/MxPidCpuRange.svg"/>
    </a>
    <a href="https://github.com/BitesPotatoBacks/MxPidCpuRange/blob/main/LICENSE">
        <img alt="License" src="https://img.shields.io/github/license/BitesPotatoBacks/MxPidCpuRange.svg"/>
    </a>
<!--     <a href="https://cash.app/$bitespotatobacks">
        <img alt="License" src="https://img.shields.io/badge/donate-Cash_App-default.svg"/>
    </a> -->
    <br>
</p>

## Project Deets
Based on my tests, the 5 modes of QoS correspond with the scheduling priority of a process. Thus, PID QoS is determined based on scheduling priority. PID CPU Range is determined based on QoS and the activity of each core in the system.

The tool uses the `ps` command to find the sched priority of PID, and uses Objective-C code to access CPU usage metrics. Unfortunately, Intel Macs are not supported by this project due to the behavior of SMP.

## Installation and Usage
1. Download the .zip file from the [latest release](https://github.com/BitesPotatoBacks/MxPidCpuRange/releases).
2. Unzip the .zip file and run the `install.sh` script in your terminal, like so: `sudo bash PATH/TO/SCRIPT/install.sh -i`. To see all installer options, use arg `-h`.
3. Once the installation is complete, you may execute a command with root priveleges using `mxpidcpur`. To see all runtime options, use arg `-h`.

In the output, CPU cores available to the specifed PID(s) are preseneted in **bold**. Cores out of range will appear in gray.


## Issues
If any bugs or issues are identified or you want your system supported, please let me know in the [issues](https://github.com/BitesPotatoBacks/SudoEvade/issues) section.

## Support
If you would like to support this project, a small donation to my [Cash App](https://cash.app/$bitespotatobacks) would be much appreciated!

