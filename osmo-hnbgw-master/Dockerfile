ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-mgcp-client-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libosmo-ranap-dev \
		libosmo-rua-dev \
		libosmo-hnbap-dev \
		libasn1c-dev \
		libosmo-pfcp-dev \
		&& \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_HNBGW_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-hnbgw.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-hnbgw/+/$OSMO_HNBGW_BRANCH?format=TEXT /tmp/commit-osmo-hnbgw

RUN	cd osmo-hnbgw && \
	git fetch && git checkout $OSMO_HNBGW_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_HNBGW_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-pfcp && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hnbgw -c /data/osmo-hnbgw.cfg >/data/osmo-hnbgw.log 2>&1"]
