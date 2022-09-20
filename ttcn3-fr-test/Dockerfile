ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" fr fr-net

VOLUME	/data

COPY	FR_Tests.cfg /data/FR_Tests.cfg
COPY	FRNET_Tests.cfg /data/FRNET_Tests.cfg

ENTRYPOINT	["ttcn3-docker-run"]
