# x728-script
User Guide: https://wiki.geekworm.com/X728-script

Email: support@geekworm.com


# Update
Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

NASPi series does not support Raspberry Pi 5 hardwared due to different hardware interface.

## Software shutdown service:

PWM_CHIP=0

BUTTON=16 for x728-v1.x

BUTTON=26 for x728-v2.x


> /usr/local/bin/xSoft.sh 0 20

## Power management service
PWMCHIP=0

SHUTDOWN=5

BOOT=12


>/usr/local/bin/xPWR.sh 0 5 12

## If working with Raspberry Pi 5 hardware, the following changes need to be made after cloning the file
```
sed -i 's/xSoft.sh 0 20/xSoft.sh 4 26/g' install-sss.sh # for X728 V2.x
sed -i 's/xSoft.sh 0 20/xSoft.sh 4 16/g' install-sss.sh # for X728 V1.x

sed -i 's/xPWR.sh 0 5 12/xPWR.sh 4 5 12/g' x728-pwr.service
```
> echo "alias x728off='sudo /usr/local/bin/xSoft.sh 0 26'" >>   ~/.bashrc

> echo "alias x728off='sudo /usr/local/bin/xSoft.sh 0 16'" >>   ~/.bashrc