FROM neels/debian-jessie-build-no-ssl

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libdbd-sqlite3 \
		libdbi-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmocore-dev \
		libsmpp34-dev \
		telnet && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/openbsc.git
ADD	http://git.osmocom.org/openbsc/patch /tmp/commit-openbsc

RUN	cd openbsc && \
	git fetch && git checkout -f -B master origin/master && \
	cd openbsc && \
	autoreconf -fi && \
	./configure --enable-smpp && \
	make -j8 install

VOLUME	/data

COPY	osmo-nitb.cfg /data/osmo-nitb.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-nitb"]

#EXPOSE	
