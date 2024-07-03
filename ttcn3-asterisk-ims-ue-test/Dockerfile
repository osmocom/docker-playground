ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" asterisk

VOLUME	/data

COPY	ttcn3/Asterisk_Tests.cfg /data/Asterisk_Tests.cfg
COPY	ttcn3/ttcn3.sh           /data/ttcn3.sh

CMD	ttcn3-docker-run asterisk Asterisk_Tests
