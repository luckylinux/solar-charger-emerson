#!/bin/bash

# Copy Script
cp bin/reconfigure-can-devices.sh /usr/local/bin/reconfigure-can-devices.sh

# Copy Systemd Service File
cp systemd/services/reconfigure-can-devices.service /etc/systemd/system/reconfigure-can-devices.service

# Reload Systemd Daemon
systemctl daemon-reload

# Enable Service
systemctl enable reconfigure-can-devices.service

# Start Service
systemctl restart reconfigure-can-devices.service
