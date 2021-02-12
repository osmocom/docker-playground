ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" bts

VOLUME	/data

COPY	BTS_Tests.cfg /data/BTS_Tests.cfg

ENTRYPOINT	["ttcn3-docker-run", "bts", "BTS_Tests"]
