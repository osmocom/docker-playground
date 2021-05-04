ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmocom-nitb \
		osmocom-bsc-nat \
		libdbd-sqlite3 && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data

COPY	openbsc.cfg /data/openbsc.cfg
COPY	osmo-bsc-nat.cfg /data/osmo-bsc-nat.cfg
COPY	bscs.config /data/bscs.config

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-nitb -c /data/osmo-nitb.cfg >/data/osmo-nitb.log 2>&1"]

EXPOSE	3002/tcp 3003/tcp 4242/tcp 2775/tcp 4249/tcp
