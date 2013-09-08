#!/bin/bash
PORT=4
PUSH_TO=( xively )

while true
do
        echo "Aquiring lock"
        while [ -e /tmp/read-lock ]
        do
                sleep 1s
        done
        touch /tmp/lock
        echo "Got lock"
        filevalue=`cat /tmp/port-$index 2> /dev/null`
        VALUE=${filevalue:-0}
        for service in $PUSH_TO
        do
                TMP_FILE=/tmp/filled-$service.json
                source $service.conf
                while read line
                do
                        eval echo "$line"
                done < $service.json > $TMP_FILE
                curl_cmd=`eval echo "$CURL"`
                eval $curl_cmd
        done
        echo "Releasing lock"
        rm -rf /tmp/port-$index
        rm -rf /tmp/lock
        sleep 60
done
