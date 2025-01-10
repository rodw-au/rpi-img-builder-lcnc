#!/bin/bash
#This is for the Pi4b/400
#for the Pi 5, change the board  to bcm2712
make commit board=bcm2711
make rootfs board=bcm2711
make image board=bcm2711
