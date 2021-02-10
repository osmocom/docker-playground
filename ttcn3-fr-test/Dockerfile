ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout $OSMO_TTCN3_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_TTCN3_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	make fr fr-net

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-stop.sh /

COPY	FR_Tests.cfg /data/FR_Tests.cfg
COPY	FRNET_Tests.cfg /data/FRNET_Tests.cfg
COPY	pipework /usr/bin/pipework
COPY	docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT	["/docker-entrypoint.sh"]
