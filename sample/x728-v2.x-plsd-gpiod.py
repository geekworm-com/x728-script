#!/usr/bin/env python

import gpiod
import time

# Define the chip and lines
chipname = "gpiochip0"  #Please use gpiochip0 if using Raspberry pi 4/3 hardware
# chipname = "gpiochip4"  #Please use gpiochip4 if using Raspberry pi 5 hardware

line_offset = 6
out_line_offset = 26

# Open the GPIO chip
chip = gpiod.Chip(chipname)

# Get the input line
line = chip.get_line(line_offset)
line.request(consumer="my_program", type=gpiod.LINE_REQ_EV_BOTH_EDGES)

def print_event(event):
    if event.type == gpiod.LineEvent.RISING_EDGE:
        print("---AC Power Loss OR Power Adapter Failure---")
        print("Shutdown in 5 seconds")
        time.sleep(5)

        # Get the output line
        out_line = chip.get_line(out_line_offset)
        out_line.request(consumer="my_program", type=gpiod.LINE_REQ_DIR_OUT)
        
        out_line.set_value(1)
        time.sleep(3)
        out_line.set_value(0)
    elif event.type == gpiod.LineEvent.FALLING_EDGE:
        print("---AC Power OK, Power Adapter OK---")

try:
    # Wait for events indefinitely
    while True:
        event = line.event_wait()        
        if event:            
            event = line.event_read()
            print_event(event)
except KeyboardInterrupt:
    print("Exiting...")
finally:
    chip.close()
