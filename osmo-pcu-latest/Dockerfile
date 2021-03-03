ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-pcu && \
	apt-get clean

ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/bin/osmo-pcu"]

#EXPOSE
