#!/bin/bash
# ubuntu 20.04
# restart pulseaudio to fix problems from removing analog aux cable or digital usb
#systemctl --user restart pulseaudio

# newer ubuntus
#pulseaudio --check
#pulseaudio -k [ill]
#pulseaudio --start
#sudo alsactl restore
