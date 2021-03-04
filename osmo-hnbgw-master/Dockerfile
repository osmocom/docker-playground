ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libasn1c-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_IUH_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-iuh.git
ADD	http://git.osmocom.org/osmo-iuh/patch?h=$OSMO_IUH_BRANCH /tmp/commit-osmo-mgw

RUN	cd osmo-iuh && \
	git fetch && git checkout $OSMO_IUH_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_IUH_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hnbgw -c /data/osmo-hnbgw.cfg >/data/osmo-hnbgw.log 2>&1"]
