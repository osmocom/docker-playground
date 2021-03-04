ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libdbd-sqlite3 \
			libosmo-abis-dev \
			libosmo-netif-dev \
			libosmo-sigtran-dev \
			libosmocore-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			python3 \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_HLR_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-hlr.git
ADD	http://git.osmocom.org/osmo-hlr/patch?h=$OSMO_HLR_BRANCH /tmp/commit-osmo-hlr

RUN	cd osmo-hlr && \
	git fetch && git checkout $OSMO_HLR_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_HLR_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hlr.cfg /data/osmo-hlr.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hlr -c /data/osmo-hlr.cfg >/data/osmo-hlr.log 2>&1"]

#EXPOSE
