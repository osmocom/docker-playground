ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" ggsn_tests

VOLUME	/data

COPY	GGSN_Tests.cfg /data/GGSN_Tests.cfg

CMD	ttcn3-docker-run ggsn_tests GGSN_Tests
