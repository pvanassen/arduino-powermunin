#!/bin/bash

#
# Read out the USB serial port every second and place the blink count into /tmp/blinkcount
#

DEV=/dev/ttyUSB0
echo "Initializing $DEV"
chmod o+rwx $DEV
stty -F $DEV 115200 cs8 cread clocal
rm -rf /tmp/port-*
rm -rf /tmp/lock

echo "Starting main loop on $DEV"

# Loop
while read line
do
        IFS=' ' read -a array <<< "$line"
        echo "Aquiring lock for read"
        while [ -e /tmp/read-lock ]
        do
                sleep 1s
        done
        touch /tmp/lock
        echo "Got lock for read"
        for index in "${!array[@]}"
        do
                filevalue=`cat /tmp/port-$index 2> /dev/null`
                oldvalue=${filevalue:-0}
                newvalue=$((${array[index]}+$oldvalue))
                echo "Found ${array[index]} on port $index. File value is $filevalue. Previous value was $oldvalue. New value will be $newvalue"
                echo "$newvalue" > /tmp/port-$index
        done
        echo "Releasing lock for read"
        rm /tmp/lock
done < /dev/ttyUSB0
