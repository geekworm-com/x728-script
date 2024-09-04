#!/bin/bash

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# Check if enough command line arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pwm_chip> <button_pin>" >&2
    exit 1
fi

PWMCHIP=$1
BUTTON=$2

SLEEP=4

# Checks if the passed parameter is an integer

re='^[0-9\.]+$'
if ! [[ $PWMCHIP =~ $re ]] ; then
   echo "error: pwm_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Your device will be shutting down in $SLEEP seconds..."

gpioset --mode=time -s $SLEEP $PWMCHIP $BUTTON=1
