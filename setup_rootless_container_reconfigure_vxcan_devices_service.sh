#!/bin/bash

# Copy Script
cp bin/reconfigure-vxcan-devices.sh /usr/local/bin/reconfigure-vxcan-devices.sh

# Copy Systemd Service File
cp systemd/services/reconfigure-vxcan-devices.service /etc/systemd/system/reconfigure-vxcan-devices.service

# Reload Systemd Daemon
systemctl daemon-reload

# Enable Service
systemctl enable reconfigure-vxcan-devices.service

# Start Service
systemctl restart reconfigure-vxcan-devices.service
