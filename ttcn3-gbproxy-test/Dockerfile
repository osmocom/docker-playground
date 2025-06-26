ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan
ARG	OSMO_TTCN3_BRANCH="master"

# Some tests fail with titan 11.1.0 (OS#6800)
ENV	TITAN_VERSION=9.0.0

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" gbproxy

VOLUME	/data

COPY	GBProxy_Tests.cfg /data/GBProxy_Tests.cfg

ENTRYPOINT	["ttcn3-docker-run", "gbproxy", "GBProxy_Tests"]
