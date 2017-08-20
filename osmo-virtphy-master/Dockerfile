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

RUN	git clone git://git.osmocom.org/osmocom-bb.git
ADD	http://git.osmocom.org/osmocom-bb/patch /tmp/commit

RUN	cd osmocom-bb/src/host/virt_phy && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

WORKDIR	/data
CMD	["/usr/local/sbin/virtphy","-s","/data/osmocom_l2"]

#EXPOSE	3002/tcp 3003/tcp 4242/tcp 2775/tcp 4249/tcp
