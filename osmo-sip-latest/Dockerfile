ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-sip-connector && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-sip-connector.cfg /data/osmo-sip-connector.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-sip-connector -c /data/osmo-sip-connector.cfg >/data/osmo-sip-connector.log 2>&1"]

#EXPOSE
