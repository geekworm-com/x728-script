#!/bin/bash

# GPIO chip and line offsets
# Note that you need to provide a different gpiochip number on Pi 0,1,2,3,4 (0) and Pi 5 (4).
chipname="gpiochip0"    #use gpiochip0 if using raspberry pi 4/3 hardware
#chipname="gpiochip4"   #use gpiochip4 if using raspberry pi 5 hardware

line_offset=6
out_line_offset=26

echo $chipname
echo $line_offset
echo $out_line_offset

# Set direction of output line
# gpioset $chipname $out_line_offset=1

# Function to handle events
print_event() {    
    if [[ "$1" == "FALLING" ]]; then
        echo "---AC Power Loss OR Power Adapter Failure---"
        # echo "Shutdown in 5 seconds"
        sleep 5
        gpioset $chipname $out_line_offset=1
        sleep 3
        gpioset $chipname $out_line_offset=0
    elif [[ "$1" == "RISING" ]]; then
        echo "---AC Power OK, Power Adapter OK---"
    fi
}

# Monitor events indefinitely
gpiomon $chipname $line_offset |
while read -r line; do
    event=$(echo $line | cut -d' ' -f2) 
    echo $event
    print_event $event
done
