ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-stp && \
	apt-get clean

WORKDIR	/data

VOLUME	/data
COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
