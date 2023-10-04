ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan

ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" epdg

VOLUME	/data

COPY	EPDG_Tests.cfg /data/EPDG_Tests.cfg

CMD	ttcn3-docker-run epdg EPDG_Tests
