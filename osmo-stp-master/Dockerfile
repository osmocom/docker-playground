FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && apt-get install -y \
	telnet \
	libosmocore-dev \
	libosmo-netif-dev

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/libosmo-sccp.git
ADD	http://git.osmocom.org/libosmo-sccp/patch /tmp/commit
RUN	cd libosmo-sccp && \
	git pull && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-stp.cfg /data/

CMD	/usr/local/bin/osmo-stp -c /data/osmo-stp.cfg

EXPOSE	2905 14001 4239
