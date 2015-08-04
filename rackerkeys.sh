#!/usr/bin/env bash

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
