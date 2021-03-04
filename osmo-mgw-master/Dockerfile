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
			libosmo-sccp-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmotrau)" \
			"pkgconfig(libosmocoding)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_MGW_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-mgw.git
ADD	http://git.osmocom.org/osmo-mgw/patch?h=$OSMO_MGW_BRANCH /tmp/commit-osmo-mgw


RUN	cd osmo-mgw && \
	git fetch && git checkout $OSMO_MGW_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_MGW_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-mgw.cfg /data/osmo-mgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-mgw -c /data/osmo-mgw.cfg >/data/osmo-mgw.log 2>&1"]
