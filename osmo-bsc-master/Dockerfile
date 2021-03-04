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
			libosmo-abis-dev \
			libosmo-netif-dev \
			libosmo-sccp-dev \
			libosmo-sigtran-dev \
			libosmo-mgcp-client-dev \
			libgtp-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-mgcp-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-sccp)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_BSC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-bsc.git
ADD	http://git.osmocom.org/osmo-bsc/patch?h=$OSMO_BSC_BRANCH /tmp/commit-osmo-bsc

RUN	cd osmo-bsc && \
	git fetch && git checkout $OSMO_BSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-bsc.cfg /data/osmo-bsc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bsc -c /data/osmo-bsc.cfg >/data/osmo-bsc.log 2>&1"]

#EXPOSE
