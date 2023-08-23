ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan

ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" dia2gsup

VOLUME	/data

COPY	DIA2GSUP_Tests.cfg /data/DIA2GSUP_Tests.cfg

CMD	ttcn3-docker-run dia2gsup DIA2GSUP_Tests
