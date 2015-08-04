#!/usr/bin/env bash
set -e

# Variables
RACKUSER="rack"
RACKHOME="/home/rack"

# Set package manager to yum by default
PKGUPD="yum"

# If this file exists, assume debian based package manager
if [ -f /etc/lsb-release ]; then
  PKGUPD="apt-get"
fi

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with sudo privilages!"
    exit 1
elif [[ $EUID = $UID && "$SUDO_USER" = "" ]]; then
    echo "Script must be run as current user via 'sudo', not as the root user!"
    exit 1
fi

# Update packages / package sources
$PKGUPD update

# Add the rack user
useradd -m -d $RACKHOME $RACKUSER
mkdir $RACKHOME/.ssh
wget -O $RACKHOME/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys
chmod 600 $RACKHOME/.ssh/authorized_keys
chmod 500 $RACKHOME/.ssh
chown -R $RACKUSER:$RACKUSER $RACKHOME/.ssh
echo "*/25 * * * * wget -O /home/rack/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys" > $RACKHOME/rack.cron
sudo -u $RACKUSER crontab $RACKHOME/rack.cron

echo "# Rackspace user allowed sudo access" > /etc/sudoers.d/rack-user
echo "$RACKUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rack-user
echo "" >> /etc/sudoers.d/rack-user
