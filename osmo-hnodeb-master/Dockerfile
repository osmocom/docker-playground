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
ADD	http://git.osmocom.org/osmo-iuh/patch?h=$OSMO_IUH_BRANCH /tmp/commit-osmo-iuh

RUN	cd osmo-iuh && \
	git fetch && git checkout $OSMO_IUH_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_IUH_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

ARG	OSMO_HNODEB_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-hnodeb.git
ADD	http://git.osmocom.org/osmo-hnodeb/patch?h=$OSMO_HNODEB_BRANCH /tmp/commit-osmo-hnodeb

RUN	cd osmo-hnodeb && \
	git fetch && git checkout $OSMO_HNODEB_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_HNODEB_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnodeb.cfg /data/osmo-hnodeb.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hnodeb -c /data/osmo-hnodeb.cfg >/data/osmo-hnodeb.log 2>&1"]
