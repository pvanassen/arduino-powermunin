#!/bin/bash
PORT=4
PUSH_TO=('sense' 'xively');
while true
do
        echo "Aquiring lock for push"
        while [ -e /tmp/read-lock ]
        do
                sleep 1s
        done
        touch /tmp/read-lock
        echo "Got lock for push"
        filevalue=`cat /tmp/port-$PORT 2> /dev/null`
        VALUE=${filevalue:-0}
        for service in "${PUSH_TO[@]}"
        do
                TMP_FILE=/tmp/filled-$service.json
                source $service.conf
                while read line
                do
                        eval echo "$line"
                done < $service.json > $TMP_FILE
                curl_cmd=`eval echo "$CURL"`
                eval $curl_cmd 1> /dev/null
        done
        echo "Releasing lock for push"
        rm -rf /tmp/port-$PORT
        rm -rf /tmp/read-lock
        sleep 60
done
