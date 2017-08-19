FROM debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && apt-get install -y \
	telnet \
	libosmocore-dev

WORKDIR	/tmp

ARG	timestamp=invalid
RUN	git clone git://git.osmocom.org/openggsn.git
ADD	http://git.osmocom.org/openggsn/commit/?h=laforge/osmo-ggsn /tmp/commit
RUN	cd openggsn && \
	git checkout -f laforge/osmo-ggsn && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-ggsn.cfg /data/openggsn.cfg

CMD	cd /data && /usr/local/bin/ggsn

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
