ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-cbc && \
	apt-get clean

WORKDIR	/data

VOLUME	/data
COPY	osmo-cbc.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-cbc -c /data/osmo-cbc.cfg >/data/osmo-cbc.log 2>&1"]

EXPOSE	12345 4264 48049
