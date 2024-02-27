# Introduction
Solar Charger Interface to Emerson / Vertiv R48-3000e3

**Important: at the moment this is just a proof-of-concept. The app running inside the container does nothing for now - just an infinite loop and a Flask `Hello World` example.**

# Device Setup
Please follow the instruction in my other Github Repository in order to rename USB devices names and CAN interfaces names: 
https://github.com/luckylinux/solar-controller/?tab=readme-ov-file#rename-can-interface-name-and-usb-can-device-name

**IMPORTANT**
Note: the network device names MUST be **stritcly** (NOT equal to !) under <IFNAMSIZ> characters long. Currently this is set to 16 characters ! Therefore interface names only up to and including 15 characters are supported !
See https://github.com/torvalds/linux/blob/master/include/uapi/linux/if.h
If you exceed that, you will get an error such as Error: argument "grid-charger-0-container" is wrong: "name" not a valid ifname

It is therefore suggested the following name conventions, so that the names are kept short. An additional 2 characters are required to run Podman/Docker with vxcan (need to add "-h" for host vxcan device / "-c" for container vxcan device).

Grid
- can-grid-xy and usb-grid-xy

Diesel or Generator
- can-dies-xy and usb-dies-xy (short for Diesel)
- can-gen-xy and usb-gen-xy (better than dying :D)

Inverter (double Power Conversion)
- can-inv-xy and usb-inv-xy

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
ip link set down can-grid-00
ip link set can-grid-00 type can bitrate 125000 restart-ms 1500
ip link set up can-grid-00
```

4. If your CAN USB Adapter has some LED lights, they should all turn on now

# What Works

Debian-based Image (`Dockerfile-Debian`) and Alpine-based Images (`Dockerfile-Alpine`) both seem to work.

The CAN adapter can be brought up.


## Rootful Podman / Docker
Running as Root (Rootfull Docker or Rootfull Podman).

### Privileged Mode
:white_check_mark: This works, but has the downside that the entire /dev folder is now accessible by the container.

```
./build.sh
podman-compose -f docker-compose-rootfull-privileged.yml up -d
```

### Unprivileged Mode
:x: Not possible to configure Network Interfaces or Network Devices.

```
./build.sh
podman-compose -f docker-compose-rootfull-unprivileged.yml up -d
```

### Host-Device Mode
:x: Does not currently work (tested using Podman). Requires the setting `network_backend` in /etc/containers/containers.conf (Podman) to be set to `cni` instead of `netavark` (default).

Probably some similar setting in the case of Docker are also required.

However, using podman-compose, this method tries to bring up an `eth1` Network Interface which doesn't exist !

```
./build.sh
podman-compose -f docker-compose-rootfull-host-device.yml up -d
```

## Rootless Podman / Docker
Running as an unprivileged User (Rootless Docker or Rootless Podman).

The "catch" is that you need to run a script (or a service/daemon) as root to (re)configure the CAN Adapters **AFTER** the container (re)starts.

This is because you need to first spin up the container, get its DOCKERPID / PODMANPID, then use that to set the namespace name ("assign the CAN interface to be managed by the container").

To handle the setup (and possibly the configuration within the container) it has been decided to just list the names in the folder:
```
mkdir -p /etc/can/adapters.d
touch /etc/can/adapters.d/can-grid-00
touch /etc/can/adapters.d/can-grid-01
...
```

The file contents doesn't matter, at least for now.

### can using Podman / Docker Namespaces
:white_check_mark: This is the more "direct" approach. The physical hardware device is "assigned" to the Container. If you run `ip link` as root you will notice that the device names are no longer available. This is because they are exclusively within the Container's Namespace now.

Run as User
```
./build.sh
podman-compose -f docker-compose-rootless-can-or-vxcan.yml up -d
```

Run as Root (for testing - permanent solution is a Systemd Service / OpenRC Service):
```
./bin/reconfigure-can-devices.sh
```

### vxcan using Podman / Docker Namespaces
:white_check_mark: This is a bit more "articulated". The host and the container communicate between each other using a Virtual CAN Adapter (called $device-h for Host and $device-c for Container). Then, the traffic between host virtual device $device-h and the physical device $device is forwarded (bidirectionally) through the setup done using `cangw` (Debian/Ubuntu: part of `can-utils` Package - `sudo apt-get install can-utils`).

```
./build.sh
podman-compose -f docker-compose-rootless-can-or-vxcan.yml up -d
```

Run as Root (for testing - permanent solution is a Systemd Service / OpenRC Service):
```
./bin/reconfigure-vxcan-devices.sh
```

### vcan using Podman / Docker Namespaces
:question: Probably not relevant for this use case (multiple virtual adapters accessing the same CAN network is NOT required here). This could however be useful in case of multi-CAN devices or multi-CAN container-to-host communication.

# Notes and References
Try to implement some of the other strategies outlined in https://github.com/luckylinux/solar-controller/?tab=readme-ov-file#use-canbus-within-docker-image.

The ideal goal would be to run without needing root access.

In particular, the vxcan tool seem to be promising: 
- https://www.lagerdata.com/articles/forwarding-can-bus-traffic-to-a-docker-container-using-vxcan-on-raspberry-pi.
- https://www.systec-electronic.com/en/demo/blog/article/news-socketcan-docker-the-solution

This presentation in particular was very helpful in setting up Rootless Docker / Rootless Podman: https://chemnitzer.linux-tage.de/2021/media/programm/folien/210.pdf
