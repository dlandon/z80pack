FROM phusion/baseimage:jammy-1.0.4

LABEL maintainer="dlandon"

ENV	DEBCONF_NONINTERACTIVE_SEEN="true" \
	DEBIAN_FRONTEND="noninteractive" \
	DISABLE_SSH="true" \
	HOME="/root" \
	LC_ALL="C.UTF-8" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8" \
	TZ="Etc/UTC" \
	TERM="xterm" \
	Z80PACK_VERS="1.37" \
	CPMTOOLS_VERS="2.23"

COPY init /etc/my_init.d/

RUN	rm -rf /etc/service/cron /etc/service/syslog-ng

RUN	apt-get update && \
	apt-get -y upgrade -o Dpkg::Options::="--force-confold" && \
	apt-get -y install wget tzdata make gcc nano sudo && \
	apt-get -y install libncurses5-dev libncursesw5-dev shellinabox && \
	apt-get -y dist-upgrade -o Dpkg::Options::="--force-confold"

RUN	cd ~ && \
	wget https://github.com/udo-munk/z80pack/archive/refs/tags/$Z80PACK_VERS.tar.gz && \
	tar xzvf $Z80PACK_VERS.tar.gz && \
	mv z80pack-$Z80PACK_VERS z80pack && \
	rm $Z80PACK_VERS.tar.gz

RUN	cd ~/z80pack/cpmsim/srcsim && \
	make -fMakefile.linux && \
	make -fMakefile.linux clean

RUN	cd ~/z80pack/cpmsim/srctools && \
	sed -i "s/"#INSTALLDIR="/"INSTALLDIR=/"" Makefile && \
	make && \
	make install && \
	make clean

RUN	cd ~ && \
	wget http://www.moria.de/~michael/cpmtools/files/cpmtools-$CPMTOOLS_VERS.tar.gz && \
	tar xzvf cpmtools-$CPMTOOLS_VERS.tar.gz && \
	mv cpmtools-$CPMTOOLS_VERS cpmtools && \
	cd cpmtools && \
	./configure && make && make install && \
	cd ~ && \
	rm cpmtools-$CPMTOOLS_VERS.tar.gz && \
	rm -r cpmtools

RUN	cd ~/z80pack/cpmsim/disks/library && \
	mkdir -p ../backups && \
	cp -p * ../backups

RUN	sed -i s#SHELL=/bin/sh#SHELL=/bin/bash#g /etc/default/useradd && \
	useradd -d "/root/z80pack/cpmsim" "vintage" && \
	adduser "vintage" sudo && \
	echo "vintage:computer" | chpasswd

RUN	mv "/etc/shellinabox/options-enabled/00+Black on White.css" "/etc/shellinabox/options-enabled/00_Black on White.css" && \
	mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00+White On Black.css"

RUN	apt-get -y remove wget make gcc libncurses5-dev libncursesw5-dev && \
	apt-get -y autoremove && \
	rm -rf /tmp/* /var/tmp/* && \
	chmod +x /etc/my_init.d/*.sh && \
	/etc/my_init.d/20_apt_update.sh

VOLUME ["/config"]

EXPOSE 4200

CMD ["/sbin/my_init"]
