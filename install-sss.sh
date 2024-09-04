#!/bin/bash

# Install soft shutdown script (sss)
echo "Start installing the soft shutdown script (sss)..."

sudo cp -f ./xSoft.sh                /usr/local/bin/

# echo "Create a alias 'x728off' command to execute the software shutdown"
# echo "alias x728off='sudo /usr/local/bin/xSoft.sh 0 26'" >>   ~/.bashrc
# source ~/.bashrc

echo "Soft shutdown script (sss) installed"