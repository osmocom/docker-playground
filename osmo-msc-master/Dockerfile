ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libasn1c-dev \
			libdbd-sqlite3 \
			libdbi-dev \
			libosmo-abis-dev \
			libosmo-mgcp-client-dev \
			libosmo-gsup-client-dev \
			libosmo-netif-dev \
			libosmo-ranap-dev \
			libosmo-sccp-dev \
			libosmo-sigtran-dev \
			libosmocore-dev \
			libsmpp34-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libasn1c)" \
			"pkgconfig(libosmo-gsup-client)" \
			"pkgconfig(libosmo-mgcp-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-ranap)" \
			"pkgconfig(libosmo-sccp)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libsmpp34)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_MSC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-msc.git
ADD	http://git.osmocom.org/osmo-msc/patch?h=$OSMO_MSC_BRANCH /tmp/commit-osmo-msc

RUN	cd osmo-msc && \
	git fetch && git checkout $OSMO_MSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_MSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-msc.cfg /data/osmo-msc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-msc -c /data/osmo-msc.cfg >/data/osmo-msc.log 2>&1"]

#EXPOSE
