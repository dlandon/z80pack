FROM phusion/baseimage:jammy-1.0.4

LABEL maintainer="dlandon"

ENV	DEBCONF_NONINTERACTIVE_SEEN="true" \
	DEBIAN_FRONTEND="noninteractive" \
	DISABLE_SSH="true" \
	HOME="/root" \
	LC_ALL="C.UTF-8" \
	LANG="en_US.UTF-8" \
	TZ="Etc/UTC" \
	TERM="xterm" \
	Z80PACK_VERS="1.37" \
	CPMTOOLS_VERS="2.24"

COPY init /etc/my_init.d/
COPY packages /root/packages/

RUN	rm -rf /etc/service/cron

RUN apt-get update --allow-releaseinfo-change && \
	apt-get install -y --no-install-recommends ca-certificates tzdata sudo nano shellinabox \
		make gcc libncurses5-dev libncursesw5-dev

# Build z80pack and cpmtools
RUN cd /root && \
    # z80pack
    tar xzf packages/z80pack-${Z80PACK_VERS}.tar.gz && \
    mv z80pack-${Z80PACK_VERS} z80pack && \
    cd z80pack/cpmsim/srcsim && \
    make -f Makefile.linux && make -f Makefile.linux clean && \
    cd ../srctools && \
    sed -i 's/#INSTALLDIR=/INSTALLDIR=/' Makefile && \
    make && make install && make clean && \
    # cpmtools
    cd /root && \
    tar xzf packages/cpmtools-${CPMTOOLS_VERS}.tar.gz && \
    mv cpmtools-${CPMTOOLS_VERS} cpmtools && \
    cd cpmtools && \
    ./configure && make && make install && \
    # cleanup sources and tarballs but keep /root/z80pack
    cd /root && rm -rf cpmtools /root/packages && \
    # remove build-only tools
    apt-get purge -y make gcc libncurses5-dev libncursesw5-dev

RUN	cd ~/z80pack/cpmsim/disks/library && \
	mkdir -p ../backups && \
	cp -p * ../backups

RUN	sed -i s#SHELL=/bin/sh#SHELL=/bin/bash#g /etc/default/useradd && \
	useradd -d "/root/z80pack/cpmsim" "vintage" && \
	adduser "vintage" sudo && \
	echo "vintage:computer" | chpasswd

RUN	mv "/etc/shellinabox/options-enabled/00+Black on White.css" "/etc/shellinabox/options-enabled/00_Black on White.css" && \
	mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00+White On Black.css"

RUN	chmod +x /etc/my_init.d/*.sh && \
	apt-get -y upgrade -o Dpkg::Options::="--force-confold" && \
	apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/config"]

EXPOSE 4200

CMD ["/sbin/my_init"]
