ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" bsc-nat

VOLUME	/data

COPY	BSCNAT_Tests.cfg /data/BSCNAT_Tests.cfg

CMD	ttcn3-docker-run bsc-nat BSCNAT_Tests
