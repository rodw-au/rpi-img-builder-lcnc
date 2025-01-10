#!/bin/bash
#This is for the Pi5
#for the Pi 4b, change the board  to bcm2711
make commit board=bcm2712
make rootfs board=bcm2712
make image board=bcm2712
