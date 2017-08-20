FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && apt-get install -y \
	telnet \
	libosmocore-dev \
	libosmo-abis-dev \
	libosmo-netif-dev \
	libosmo-sccp-dev \
	libsmpp34-dev \
	libgtp-dev

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/openbsc.git
ADD	http://git.osmocom.org/openbsc/patch /tmp/commit-openbsc

RUN	cd openbsc/openbsc && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure --enable-nat --enable-osmo-bsc --enable-smpp && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo_sgsn.cfg /data/osmo_sgsn.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-sgsn"]

EXPOSE	23000/udp 4245/tcp 4249/tcp
