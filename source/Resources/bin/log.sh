#!/usr/bin/env bash

logpath=~/Library/Logs/AppleScript
if [ ! -d logpath ] ; then 
	mkdir -p $logpath
fi
logfile=${logpath}/$1.log

# Log a line of text to ~/Library/Logs/AppleScript/{first aargument}.log
#Log een regel tekst naar ~/Library/Logs/ArchiPunt/{scriptnaam}.log
echo "`date -u`: $2" >> ${logfile} 2>&1
