FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sccp-dev \
		libsmpp34-dev \
		libgtp-dev &&
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/openbsc.git
ADD	http://git.osmocom.org/openbsc/patch /tmp/commit-openbsc

RUN	git clone git://git.osmocom.org/osmo-bts.git
ADD	http://git.osmocom.org/osmo-bts/patch /tmp/commit-osmo-bts

RUN	cd openbsc/openbsc && \
	git fetch && git checkout -f -B master origin/master

RUN	cd osmo-bts && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure --enable-trx && \
	make -j8 install

VOLUME	/data

COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
	# send GSMTAP data to .230 which is the ttcn3-sysinfo test
CMD	["/usr/local/bin/osmo-bts-virtual", "-i", "172.18.0.230"]

#EXPOSE	
