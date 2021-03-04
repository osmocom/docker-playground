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
			libulfius-dev \
			&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libulfius)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_CBC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-cbc.git
ADD	http://git.osmocom.org/osmo-cbc/patch?h=$OSMO_CBC_BRANCH /tmp/commit-osmo-cbc

RUN	cd osmo-cbc && \
	git fetch && git checkout $OSMO_CBC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_CBC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-cbc.cfg /data/osmo-cbc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-cbc -c /data/osmo-cbc.cfg >/data/osmo-cbc.log 2>&1"]

#EXPOSE
