#!/bin/sh
#
# 20_apt_update.sh
#

# Update repositories
echo "Performing updates..."
apt-get update --allow-releaseinfo-change 2>&1 | tee /tmp/test_update

# Verify that the updates will work.
if ! grep -q 'Failed' /tmp/test_update; then
	# Perform Upgrade
	apt-get -y upgrade -o Dpkg::Options::="--force-confold"

	# Clean + purge old/obsoleted packages
	apt-get -y autoremove
	apt-get clean -y
else
	echo "Warning: Unable to update!  Check Internet connection."
fi
