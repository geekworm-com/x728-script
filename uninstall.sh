#!/bin/bash

# Uninstall x728 installation script
sudo systemctl stop x728-pwr
sudo systemctl disable x728-pwr
file_path="/lib/systemd/system/x728-pwr.service"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/x728-pwr.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_pwr"

if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

# Remove the xoff allias on .bashrc file
sudo sed -i '/x728off/d' ~/.bashrc
source ~/.bashrc

file_path="/usr/local/bin/x728-softsd.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_soft"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi
