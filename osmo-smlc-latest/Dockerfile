ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-smlc && \
	apt-get clean

WORKDIR	/data

VOLUME	/data
COPY	osmo-smlc.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-smlc -c /data/osmo-smlc.cfg >/data/osmo-smlc.log 2>&1"]
