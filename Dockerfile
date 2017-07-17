FROM phusion/baseimage:0.9.22

MAINTAINER dlandon

ENV \
	DEBCONF_NONINTERACTIVE_SEEN="true" \
	DEBIAN_FRONTEND="noninteractive" \
	DISABLESSH="true" \
	HOME="/root" \
	LC_ALL="C.UTF-8" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8" \
	TZ="Etc/UTC" \
	TERM="xterm"

COPY 20_apt_update.sh /etc/my_init.d/
COPY 30_firstrun.sh /etc/my_init.d/

RUN \
	# Disable Cron, Syslog
	rm -rf /etc/service/cron /etc/service/syslog-ng && \

	# Install Dependencies
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y dist-upgrade && \
	apt-get -y install wget tzdata make gcc nano && \
	apt-get -y install libncurses5-dev libncursesw5-dev && \
	apt-get -y install shellinabox sudo && \

	# Install z80pack and complie modules.
	cd ~ && \
	wget http://www.autometer.de/unix4fun/z80pack/ftp/z80pack-1.34.tgz && \
	tar xzvf z80pack-1.34.tgz && \
	mv z80pack-1.34 z80pack	&& \
	rm z80pack-1.34.tgz && \

	# Compile simulator.
	cd ~/z80pack/cpmsim/srcsim && \
	make -fMakefile.linux && \
	make -fMakefile.linux clean && \

	# Compile support tools.
	cd ~/z80pack/cpmsim/srctools && \
	sed -i "s/"#INSTALLDIR="/"INSTALLDIR=/"" Makefile && \
	make && \
	make install && \
	make clean && \
	cd ~ && \

	# Install cpmtools and compile.
	wget http://www.moria.de/~michael/cpmtools/files/cpmtools-2.21-snapshot.tar.gz && \
	tar xzvf cpmtools-2.21-snapshot.tar.gz && \
	mv cpmtools-2.21 cpmtools && \
	cd cpmtools && \
	./configure && make && make install && \
	cd ~ && \
	rm cpmtools-2.21-snapshot.tar.gz && \
	rm -r cpmtools && \

	# Make backup of disk images.
	cd ~/z80pack/cpmsim/disks/library && \
	cp -p * ../backups && \

	apt-get -y remove wget && \

	chmod -R +x /etc/my_init.d/ && \

	# Create user account for shell in a box
	useradd -d "/root/z80pack/cpmsim/" "vintage" && \
	adduser "vintage" sudo && \
	echo "vintage:computer" | chpasswd && \

	# Add white on black screen default to shell in a box
	echo "OPTS='--css white-on-black.css'" >> "/etc/default/shellinabox" && \

	# Clean APT install files
	apt-get clean -y

VOLUME \
	/config \

EXPOSE 4200

CMD ["/sbin/my_init"]
