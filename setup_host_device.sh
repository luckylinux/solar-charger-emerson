#!/bin/bash

# Enter device name
device=${1}

# Distribution
distribution="debian" # debian, ubuntu, fedora, ...

# Error if not running as root
if [[ $EUID -ne 0 ]]
then
    echo "You must be root to do this." 1>&2
    exit 1
fi

# Error if not set or if invalid
if [[ ! -v device ]] || [[ ! -h /sys/class/net/$device ]]
then
   echo "Device <$device> is either not set or invalid. Aborting !"
   exit 2
fi

# Switch directory
if [[ $distribution == "debian" ]] || [ $distribution == "ubuntu" ]]
then
#    configfolder="/etc/containers/networks"
    configfolder="/etc/cni/net.d/"
elif [[ $distribution == "fedora" ]]
then
    configfolder="/etc/cnd/net.d"
else
    # Error
    echo "Support for distribution <$distribution> has not been implemented. Aborting !"
    exit 3
fi

# Generate Random Network ID
networkid=$(pwgen -s 64 1)

# Write to file
# Works for /etc/containers/networks on Debian/Ubuntu
#tee $configfolder/$device.json <<EOF
#{
#   "cniVersion": "0.4.0",
#   "name": "$device",
#   "id": "$networkid",
#   "type": "host-device",
#   "device": "$device",
#   "kernelpath": "/sys/class/net/$device"
#}
#EOF

# Works for /etc/cni/net.d on Debian/Ubuntu
# Example: https://github.com/containers/podman/discussions/10571#discussioncomment-833432
tee $configfolder/$device.conflist <<EOF
{
   "cniVersion": "0.4.0",
   "name": "$device",
   "plugins": [
      {
         "type": "host-device",
         "device": "$device",
         "kernelpath": "/sys/class/net/$device"
      }
    ]
}
EOF


#   "id": "$networkid",
#   "type": "host-device",
#   "device": "$device",
