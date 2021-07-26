#!/bin/bash

# AUTHOR | Ethan Shearer
# DESCRIPTION | ENABLE PERSISTENT LOGS LINUX

if [ `id -u` != 0 ]; then # Check to see if the the command id -u is equal to the uid of root's (0)
    echo `id -u` # If not we echo the current users uid to the terminal.
    echo Please run this script as root or using sudo
    exit
fi

mkdir -p /var/log/journal
chmod 2755 /var/log/journal
chown root:systemd-journal /var/log/journal
echo "SystemMaxUse=50M" >> /etc/systemd/journald.conf
echo "Storage=auto" >> /etc/systemd/journald.conf
systemctl restart systemd-journald