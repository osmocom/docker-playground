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
			libosmo-netif-dev \
			libosmo-sccp-dev \
			libosmo-sigtran-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-sccp)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_SMLC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-smlc.git
ADD	http://git.osmocom.org/osmo-smlc/patch?h=$OSMO_SMLC_BRANCH /tmp/commit-osmo-smlc

RUN	cd osmo-smlc && \
	git fetch && git checkout $OSMO_SMLC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_SMLC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-smlc.cfg /data/osmo-smlc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-smlc -c /data/osmo-smlc.cfg >/data/osmo-smlc.log 2>&1"]

#EXPOSE
