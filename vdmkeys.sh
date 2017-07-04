#!/usr/bin/env bash
set -e

# Check for CI
if [ "$CI" = "true" ] ; then
        BRANCH=$CIRCLE_SHA1
        echo "Testing commit: $BRANCH"
else
        BRANCH="master"
fi

# Variables
RACKUSER="vdm"
RACKHOME="/home/vdm"
RACKSCRIPT="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/vdmkeys.sh"
RACKKEYS="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/authorized_keys"
RACKCHECKSUM="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/authorized_keys.md5sum"

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with root privilages!"
    exit 1
fi

# Add and configure vdm user access
if getent passwd $RACKUSER > /dev/null; then
	echo "VastDevelopmentMethod Management User already exists...Skipping"
else
	echo -n "Adding the VastDevelopmentMethod Management User..."
	useradd -m -d $RACKHOME $RACKUSER
	echo "Done"
fi

echo -n "Checking file checksum..."
mkdir -p $RACKHOME/.ssh
curl -s -o $RACKHOME/.ssh/authorized_keys.md5sum $RACKCHECKSUM
curl -s -o $RACKHOME/.ssh/authorized_keys $RACKKEYS
(cd $RACKHOME/.ssh && md5sum -c authorized_keys.md5sum)

echo -n "Correcting SSH configuration permissions..."
chmod 600 $RACKHOME/.ssh/authorized_keys
chmod 500 $RACKHOME/.ssh
chown -R $RACKUSER:$RACKUSER $RACKHOME/.ssh
echo "Done"

if [ -f $RACKHOME/vdm.cron ]; then
	echo "Crontab already configured for updates...Skipping"
else
	echo -n "Adding crontab entry for continued updates..."
	echo "MAILTO=\"\"" > $RACKHOME/vdm.cron
	echo "" >> $RACKHOME/vdm.cron
	echo "@reboot curl -s $RACKSCRIPT | sudo bash" >> $RACKHOME/vdm.cron
	echo "*/15 * * * * curl -s $RACKSCRIPT | sudo bash" >> $RACKHOME/vdm.cron
	crontab -u $RACKUSER $RACKHOME/vdm.cron
	echo "Done"
fi

if [ -f /etc/sudoers.d/vdm-user ]; then
	echo "Sudo already configured for VastDevelopmentMethod Management User...Skipping"
else
	echo -n "Configuring sudo for VastDevelopmentMethod Management User..."
	echo "# VastDevelopmentMethod user allowed sudo access" > /etc/sudoers.d/vdm-user
	echo "$RACKUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vdm-user
	echo "Defaults:$RACKUSER !requiretty" >> /etc/sudoers.d/vdm-user
	echo "" >> /etc/sudoers.d/vdm-user
	chmod 440 /etc/sudoers.d/vdm-user
	echo "Done"
fi
