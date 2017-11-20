FROM laforge/debian-stretch-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libasn1c-dev && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/osmo-iuh.git
ADD	http://git.osmocom.org/osmo-iuh/patch /tmp/commit-osmo-mgw

RUN	cd osmo-iuh && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-hnbgw", "-c", "/data/osmo-hnbgw.cfg"]
