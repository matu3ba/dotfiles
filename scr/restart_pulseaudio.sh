#!/bin/bash
# restart pulseaudio to fix problems from removing analog aux cable or digital usb
systemctl --user restart pulseaudio
