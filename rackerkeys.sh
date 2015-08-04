#!/usr/bin/env bash
set -e

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with sudo privilages!"
    exit 1
elif [[ $EUID = $UID && "$SUDO_USER" = "" ]]; then
    echo "Script must be run as current user via 'sudo', not as the root user!"
    exit 1
fi

PKGUPD="yum"

if [ -f /etc/lsb-release ]; then
  PKGUPD="apt-get"
fi

$PKGUPD update

useradd -m -d /home/rack rack
mkdir /home/rack/.ssh
wget -O /home/rack/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys
chmod 600 /home/rack/.ssh/authorized_keys
chmod 500 /home/rack/.ssh
chown -R rack:rack /home/rack/.ssh
echo "*/25	*	*	*	* wget -O /home/rack/.ssh/authorized_keys https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/authorized_keys" > /home/rack/rack.cron
sudo -u rack crontab /home/rack/rack.cron

echo "# Rackspace user allowed sudo access" > /etc/sudoers.d/rack-user
echo "rack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rack-user
echo "" >> /etc/sudoers.d/rack-user
