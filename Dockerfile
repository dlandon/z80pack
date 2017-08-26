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

COPY init /etc/my_init.d/

RUN \
	# Disable Cron, Syslog
	rm -rf /etc/service/cron /etc/service/syslog-ng && \

	# Install Dependencies
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y dist-upgrade && \
	apt-get -y install wget tzdata make gcc nano && \

	# z80pack
	apt-get -y install libncurses5-dev libncursesw5-dev && \

	# Shell in a box
	apt-get -y install shellinabox sudo && \

	# Install z80pack and complie modules.
	cd ~ && \
	wget http://www.autometer.de/unix4fun/z80pack/ftp/z80pack-1.35.tgz && \
	tar xzvf z80pack-1.35.tgz && \
	mv z80pack-1.35 z80pack	&& \
	rm z80pack-1.35.tgz && \

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

	chmod -R +x /etc/my_init.d/ && \

	# Create user account for shell in a box
	useradd -d "/root/z80pack/cpmsim" "vintage" && \
	adduser "vintage" sudo && \
	echo "vintage:computer" | chpasswd && \

	# Set white on black screen as default to shell in a box
	mv "/etc/shellinabox/options-enabled/00+Black on White.css" "/etc/shellinabox/options-enabled/00_Black on White.css" && \
	mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00+White On Black.css" && \

	# Remove unneeded packages and clean APT install files
	apt-get -y autoremove && \
	apt-get -y remove wget make gcc libncurses5-dev libncursesw5-dev && \
	apt-get clean -y

VOLUME \
	/config \

EXPOSE 4200

CMD ["/sbin/my_init"]
