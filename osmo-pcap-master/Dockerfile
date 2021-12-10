ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libosmocore-dev \
			libzmq3-dev \
			&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libzmq)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_PCAP_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-pcap.git
ADD	http://git.osmocom.org/osmo-pcap/patch?h=$OSMO_PCAP_BRANCH /tmp/commit-osmo-pcap

RUN	cd osmo-pcap && \
	git fetch && git checkout $OSMO_PCAP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_PCAP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-pcap-client.cfg /data/osmo-pcap-client.cfg
#COPY	osmo-pcap-server.cfg /data/osmo-pcap-server.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-pcap-client -c /data/osmo-pcap-client.cfg > /data/osmo-pcap-client.log 2>&1"]

#EXPOSE
