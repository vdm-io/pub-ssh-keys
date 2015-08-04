#!/usr/bin/env bash
set -e

# Variables
RACKUSER="rack"
RACKHOME="/home/rack"

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with sudo privilages!"
    exit 1
elif [[ $EUID = $UID && "$SUDO_USER" = "" ]]; then
    echo "Script must be run as current user via 'sudo', not as the root user!"
    exit 1
fi

# Add and configure rack user access
echo "Adding the Rackspace Management User..."
useradd -m -d $RACKHOME $RACKUSER
echo "Configuring SSH keys for access..."
mkdir $RACKHOME/.ssh
curl -s -o $RACKHOME/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys
echo "Correcting SSH configuration permissions..."
chmod 600 $RACKHOME/.ssh/authorized_keys
chmod 500 $RACKHOME/.ssh
chown -R $RACKUSER:$RACKUSER $RACKHOME/.ssh

if [ -f $RACKHOME/rack.cron ]; then
	echo "Crontab already configured for updates...Skipping"
else
	echo "Adding crontab entry for continued updates..."
	echo "*/25 * * * * wget -O /home/rack/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys" > $RACKHOME/rack.cron
	crontab -u $RACKUSER $RACKHOME/rack.cron
fi

if [ -f /etc/sudoers.d/rack-user ]; then
	echo "Sudo already configured for Rackspace Management User...Skipping"
else
	echo "Configuring sudo for Rackspace Management User"
	echo "# Rackspace user allowed sudo access" > /etc/sudoers.d/rack-user
	echo "$RACKUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rack-user
	echo "" >> /etc/sudoers.d/rack-user
fi
