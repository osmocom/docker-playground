ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libjansson-dev \
		libnl-route-3-dev \
		libosmocore-dev \
		libosmo-netif-dev \
		libsctp-dev \
		iputils-ping \
		strace && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_UECUPS_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-uecups.git
ADD	http://git.osmocom.org/osmo-uecups/patch?h=$OSMO_UECUPS_BRANCH /tmp/commit-osmo-uecups

RUN	cd osmo-uecups && \
	git fetch && git checkout $OSMO_UECUPS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_UECUPS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-uecups-daemon.cfg /data/osmo-uecups-daemon.cfg

RUN	useradd -m --uid=1000 osmocom

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-uecups-daemon -c /data/osmo-uecups-daemon.cfg >/data/osmo-uecups-daemon.log 2>&1"]

#EXPOSE
