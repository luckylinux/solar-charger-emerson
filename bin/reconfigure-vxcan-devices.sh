#!/bin/bash

# Define container name
containername="solar-charger-emerson"

# Define username running the podman/docker process
username="stefano"

# Save current path
currentpath=$(pwd)

while true
do
   # Inspect Containers
   mapfile -t list < <( podman ps --all --format="{{.Names}}" )

   # Get current epoch time
   now=$(date +%s)

   # Get past epoch Time in which container was started (constant value)
   container_startedat=$(runuser -l $username -c "podman ps --all --format='{{.StartedAt}}' --filter name=^$containername\$")

   # Get container running duration
   container_duration_s=$((now-container_startedat))

   # Define if vxcan devices must be (re)configured
   reconfigure_devices=0

   # Define check filename
   checkfilename="/tmp/reconfigure-vxcan-devices.timestamp"
   if [[ -f $checkfilename ]]
   then
       checktimestamp=$(cat $checkfilename)
   else
       checktimestamp=0
   fi

   # Compare against container started time
   if [[ ${container_startedat} -gt ${checktimestamp} ]]
   then
       echo "Container $containername was started AFTER (Re)Configuration of vxcan Devices. Reconfiguration of vxcan Devices Necessary"
       reconfigure_devices=1
   fi

   # Is a restart of the container necessary ?
   if [[ ${reconfigure_devices} -gt 0 ]]
   then
      # Reconfigure vxcan Devices
      if [[ -d "/etc/can/adapters.d" ]]
      then
         cd "/etc/can/adapters.d"
         for d in *.adapter
         do
              # Remove .adapter from filename
	      device=${d/".adapter"/""}

              # Get namespace of the running container
              PODMANPID=$(runuser -l $username -c "podman inspect -f '{{ .State.Pid }}' $containername")

              # Echo
              echo "(Re)configuring CAN interface $device to $device-h (on the host) and $device-c (to be used within Podman/Docker namespace $PODMANPID)" 

              # Bring all interfaces down
              sudo ip link set $device down
              sudo ip link set $device-h down
              sudo nsenter -t $PODMANPID -n ip link set $device-c down

              # Delete the virtual interfaces
              sudo ip link del $device-h
              sudo ip link del $device-c

              # (Re)Configure vxcan devices
              # Note: the network device names MUST be under <IFNAMSIZ> characters long. Currently this is set to 16 characters !
              # See https://github.com/torvalds/linux/blob/master/include/uapi/linux/if.h
              # If you exceed that, you will get an error such as Error: argument "grid-charger-0-container" is wrong: "name" not a valid ifname
              sudo ip link add $device-h type vxcan peer name $device-c netns $PODMANPID

              # Setup cangw for traffic forwarding to/from the physical adapter
              sudo modprobe can-gw

              # In case of "cangw: command not found", install can-utils (e.g. `apt-get install can-utils` on Debian/Ubuntu Systems)
              cangw -A -s $device -d $device-h -e
              cangw -A -s $device-h -d $device -e

              sudo ip link set $device-h up
              sudo ip link set $device type can bitrate 125000
              sudo ip link set $device up
              sudo nsenter -t $PODMANPID -n ip link set $device-c up
         done
      else
         echo "Folder /etc/can/devices.d does not exist. No configuration is possible. Aborting !"
         exit 9
      fi

      # Save date when devices have been reconfigured
      echo "$now" > $checkfilename

      # Change back to currentpath
      cd $currentpath
   fi

   # Wait a bit
   sleep 5
done
