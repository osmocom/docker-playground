ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-remsim-server \
		osmo-remsim-client \
		osmo-remsim-bankd && \
	apt-get clean

#ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

VOLUME	/data

#COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-resmim-server >/data/osmo-resmim-server.log 2>&1"]

#EXPOSE
