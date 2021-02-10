ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" fr fr-net

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-stop.sh /

COPY	FR_Tests.cfg /data/FR_Tests.cfg
COPY	FRNET_Tests.cfg /data/FRNET_Tests.cfg
COPY	pipework /usr/bin/pipework
COPY	docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT	["/docker-entrypoint.sh"]
