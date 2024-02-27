# Introduction
Solar Charger Interface to Emerson / Vertiv R48-3000e3

**Important: at the moment this is just a proof-of-concept. The app running inside the container does nothing for now - just an infinite loop and a Flask `Hello World` example.**

# Device Setup
Please follow the instruction in my other Github Repository in order to rename USB devices names and CAN interfaces names: 
https://github.com/luckylinux/solar-controller/?tab=readme-ov-file#rename-can-interface-name-and-usb-can-device-name

# Get Started
1. Run as `root` (or possibly with `sudo`)
```
./build.sh
podman-compose up -d
```

2. Enter the container shell environment
`podman exec -it solar-charger-emerson /bin/sh`

3. Try to (re)configure the USB CAN Adapter
```
ip link set down grid-charger-0
ip link set grid-charger-0 type can bitrate 125000 restart-ms 1500
ip link set up grid-charger-0
```

4. If your CAN USB Adapter has some LED lights, they should all turn on now

# What Works
Running as Root (Root Docker or Root Podman).

The CAN adapter can be brought up.

Debian-based Image (`Dockerfile-Debian`) and Alpine-based Images (`Dockerfile-Alpine`) both seem to work.

# Next Steps
Try to implement some of the other strategies outlined in https://github.com/luckylinux/solar-controller/?tab=readme-ov-file#use-canbus-within-docker-image.

The ideal goal would be to run without needing root access.

In particular, the vxcan tool seem to be promising: 
- https://www.lagerdata.com/articles/forwarding-can-bus-traffic-to-a-docker-container-using-vxcan-on-raspberry-pi.
- https://www.systec-electronic.com/en/demo/blog/article/news-socketcan-docker-the-solution
