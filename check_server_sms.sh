#!/bin/bash
LOGDIR="/tmp/"
MOBILENUMBER=08********
PINGCOUNT=4
SERVER="192.168.2.30 192.168.2.25 192.168.2.8"
for IP in $SERVER
do
        NOW=$(date +"%Y/%m/%d %H:%M:%S")
        LOGFILE="$LOGDIR""check-""$IP"".log"
        CHECK=$(ping -c $PINGCOUNT $IP | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
        if [ $CHECK -eq 0 ]; then
                # alert 
                STATUS=0
                if [ ! -f $LOGFILE ]; then
                        gammu sendsms TEXT $MOBILENUMBER -text "Alert! Server $IP down." &> /dev/null
                else
                        LASTSTATUS=$(cat $LOGFILE | cut -d '|' -f2)
                        if [ $STATUS -lt $LASTSTATUS ]; then
                                gammu sendsms TEXT $MOBILENUMBER -text "Alert! Server $IP down." &> /dev/null
                        else
                                LASTTIMEOUT=$(cat $LOGFILE | cut -d '|' -f3 )
                                if [ ! -f "$LASTTIMEOUT" ]; then
                                        STATUS="0|""$NOW"
                                else
                                        STATUS="0|""$LASTTIMEOUT"
                                fi
                        fi
                fi
        else
                STATUS=1
        fi

        if [ ! -f $LOGFILE ]; then
                echo -n "" > $LOGFILE
        fi
        echo "$NOW|$STATUS" > $LOGFILE
done
