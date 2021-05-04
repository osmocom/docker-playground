ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-hnbgw && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-hnbgw -c /data/osmo-hnbgw.cfg >/data/osmo-hnbgw.log 2>&1"]
