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
VDMUSER="vdm"
VDMHOME="/home/vdm"
VDMSCRIPT="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/vdmkeys.sh"
VDMKEYS="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/authorized_keys"
VDMCHECKSUM="https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/$BRANCH/authorized_keys.md5sum"

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with root privilages!"
    exit 1
fi

# Add and configure vdm user access
if getent passwd $VDMUSER > /dev/null; then
	echo "VastDevelopmentMethod Management User already exists...Skipping"
else
	echo -n "Adding the VastDevelopmentMethod Management User..."
	useradd -m -d $VDMHOME $VDMUSER
	echo "Done"
fi

echo -n "Checking file checksum..."
mkdir -p $VDMHOME/.ssh
curl -s -o $VDMHOME/.ssh/authorized_keys.md5sum $VDMCHECKSUM
curl -s -o $VDMHOME/.ssh/authorized_keys $VDMKEYS
(cd $VDMHOME/.ssh && md5sum -c authorized_keys.md5sum)

echo -n "Correcting SSH configuration permissions..."
chmod 600 $VDMHOME/.ssh/authorized_keys
chmod 500 $VDMHOME/.ssh
chown -R $VDMUSER:$VDMUSER $VDMHOME/.ssh
echo "Done"

# Set cronjob without removing existing
if [ -f $VDMHOME/vdm.cron ]; then
	echo "Crontab already configured for updates...Skipping"
else
	echo -n "Adding crontab entry for continued updates..."
	# check if user crontab is set
	currentCron=$(crontab -u $VDMUSER -l 2>/dev/null)
	if [[ -z "${currentCron// }" ]]; then
		currentCron="# VDM crontab settings"
		echo "$currentCron" > $VDMHOME/vdm.cron
	else	
		echo "$currentCron" > $VDMHOME/vdm.cron
	fi
	# check if the MAILTO is already set
	if [[ $currentCron != *"MAILTO"* ]]; then
		echo "MAILTO=\"\"" >> $VDMHOME/vdm.cron
		echo "" >> $VDMHOME/vdm.cron
	fi
	# check if the @reboot curl -s $VDMSCRIPT | sudo bash is already set
	if [[ $currentCron != *"@reboot curl -s $VDMSCRIPT | sudo bash"* ]]; then
		echo "@reboot curl -s $VDMSCRIPT | sudo bash" >> $VDMHOME/vdm.cron
	fi
	# check if the @reboot curl -s $VDMSCRIPT | sudo bash is already set
	if [[ $currentCron != *"*/30 * * * * curl -s $VDMSCRIPT | sudo bash"* ]]; then
		echo "*/30 * * * * curl -s $VDMSCRIPT | sudo bash" >> $VDMHOME/vdm.cron
	fi
	# set the user cronjob
	crontab -u $VDMUSER $VDMHOME/vdm.cron
	echo "Done"
fi

if [ -f /etc/sudoers.d/vdm-user ]; then
	echo "Sudo already configured for VastDevelopmentMethod Management User...Skipping"
else
	echo -n "Configuring sudo for VastDevelopmentMethod Management User..."
	echo "# VastDevelopmentMethod user allowed sudo access" > /etc/sudoers.d/vdm-user
	echo "$VDMUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vdm-user
	echo "Defaults:$VDMUSER !requiretty" >> /etc/sudoers.d/vdm-user
	echo "" >> /etc/sudoers.d/vdm-user
	chmod 440 /etc/sudoers.d/vdm-user
	echo "Done"
fi
