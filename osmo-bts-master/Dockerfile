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
			libsmpp34-dev \
			libgtp-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocodec)" \
			"pkgconfig(libosmocoding)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmotrau)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_BTS_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-bts.git
ADD	http://git.osmocom.org/osmo-bts/patch?h=$OSMO_BTS_BRANCH /tmp/commit-osmo-bts

RUN	cd osmo-bts && \
	git fetch && git checkout $OSMO_BTS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BTS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-trx && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-bts.cfg /data/osmo-bts.cfg
COPY	Makefile.within-docker-img /Makefile

WORKDIR	/
CMD	make run

#EXPOSE
