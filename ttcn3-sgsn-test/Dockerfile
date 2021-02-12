ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" sgsn

VOLUME	/data

COPY	SGSN_Tests.cfg /data/SGSN_Tests.cfg

ENTRYPOINT	["ttcn3-docker-run", "sgsn", "SGSN_Tests"]
