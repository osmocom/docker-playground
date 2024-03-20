ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" ggsn_tests

VOLUME	/data

COPY	ttcn3/GGSN_Tests.cfg /data/GGSN_Tests.cfg

CMD	ttcn3-docker-run ggsn_tests GGSN_Tests
