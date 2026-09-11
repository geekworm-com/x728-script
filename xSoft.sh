#!/bin/bash

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# In October 2025, the Raspberry Pi OS was updated from Bookworm to Trixie. The libgpiod library in Trixie has been upgraded to version 2.2.1. 
# The syntax of the gpioset command has changed, so harry@geekworm.com updated this script.
# Refer to https://libgpiod.readthedocs.io/en/latest/gpio_tools.html#examples

# Check if enough command line arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpio_chip> <button_pin>" >&2
    exit 1
fi

GPIOCHIP=$1
BUTTON=$2

# Checks if the passed parameter is an integer

re='^[0-9]+$'
if ! [[ $GPIOCHIP =~ $re ]] ; then
   echo "error: gpio_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Requesting safe shutdown..."

# Drive the pin high for 2 seconds, then drive it low and exit.
gpioset -c "$GPIOCHIP" -t 2s,0 "$BUTTON=1"
