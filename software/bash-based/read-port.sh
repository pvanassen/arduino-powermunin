#!/bin/bash

#
# Read out the USB serial port every second and place the blink count into /tmp/blinkcount
#
DEV=/dev/ttyUSB0
echo "Initializing $DEV"
chmod o+rwx $DEV
stty -F $DEV 115200 cs8 cread clocal
rm -rf /tmp/port-*

echo "Starting main loop on $DEV"

# Loop
while read line
do
        IFS=' ' read -a array <<< "$line"
        touch /tmp/lock
        for index in "${!array[@]}"
        do
                filevalue=`cat /tmp/port-$index &> /dev/null`
        	oldvalue=${filevalue:-0}
        	newvalue=$((${array[index]}+$oldvalue))
                echo "Found ${array[index]} on port $index. File value is $filevalue. Previous value was $oldvalue. New value will be $newvalue"
                echo "${array[index]}" > /tmp/port-$index
        done
        rm /tmp/lock
done < /dev/ttyUSB0

