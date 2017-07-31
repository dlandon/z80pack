#!/bin/bash
#
# 30_firstrun.sh
#

# Search for config files, if they don't exist, copy the default ones
# Move cpm13 script if it doesn't exist.
if [ ! -f /config/cpm13 ]; then
	echo "Copying cpm13"
	cp /root/z80pack/cpmsim/cpm13 /config/
else
	echo "File cpm13 already exists"
fi

# Move cpm14 script if it doesn't exist.
if [ ! -f /config/cpm14 ]; then
	echo "Copying cpm14"
	cp /root/z80pack/cpmsim/cpm14 /config/
else
	echo "File cpm14 already exists"
fi

# Move cpm2 script if it doesn't exist.
if [ ! -f /config/cpm2 ]; then
	echo "Copying cpm2"
	cp /root/z80pack/cpmsim/cpm2 /config/
else
	echo "File cpm2 already exists"
fi

# Move cpm3 script if it doesn't exist.
if [ ! -f /config/cpm3 ]; then
	echo "Copying cpm3"
	cp /root/z80pack/cpmsim/cpm3 /config/
else
	echo "File cpm3 already exists"
fi

# Move mpm script if it doesn't exist.
if [ ! -f /config/mpm ]; then
	echo "Copying mpm"
	cp /root/z80pack/cpmsim/mpm /config/
else
	echo "File mpm already exists"
fi

# Move disks configuration if it doesn't exist
if [ ! -d /config/disks ]; then
	echo "Moving disks to config folder"
	cp -p -R /root/z80pack/cpmsim/disks/ /config/
else
	echo "Using existing disks configuration"
fi

# Move documentation to configuration
echo "Moving documentation to config folder"
cp -p -R /root/z80pack/doc/ /config/

echo "Creating symbolink links"
# cpm13
rm /root/z80pack/cpmsim/cpm13
ln -sf /config/cpm13 /root/z80pack/cpmsim/cpm13
chmod +x /config/cpm13

# cpm14
rm /root/z80pack/cpmsim/cpm14
ln -sf /config/cpm14 /root/z80pack/cpmsim/cpm14
chmod +x /config/cpm14

# cpm2
rm /root/z80pack/cpmsim/cpm2
ln -sf /config/cpm2 /root/z80pack/cpmsim/cpm2
chmod +x /config/cpm2

# cpm3
rm /root/z80pack/cpmsim/cpm3
ln -sf /config/cpm3 /root/z80pack/cpmsim/cpm3
chmod +x /config/cpm3

# mpm
rm /root/z80pack/cpmsim/mpm
ln -sf /config/mpm /root/z80pack/cpmsim/mpm
chmod +x /config/mpm

# disks
rm -r /root/z80pack/cpmsim/disks
ln -s /config/disks /root/z80pack/cpmsim

# Configure user nobody to match unRAID's settings
PUID=${PUID:-99}
PGID=${PGID:-100}
usermod -u $PUID nobody
usermod -g $PGID nobody
usermod -d /config nobody
chown -R nobody:users /config
chmod -R go+rw /config

# Change permissions on /root
chown -R root:root /root/z80pack
chmod 755 /root

# Get docker env timezone and set system timezone
echo "Setting the timezone to : $TZ"
echo $TZ > /etc/timezone
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure tzdata
echo "Date: `date`"

# Start shell in a box
echo "Starting Shell in a Box..."
service shellinabox start
