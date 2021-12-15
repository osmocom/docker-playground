ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" gbproxy

VOLUME	/data

COPY	GBProxy_Tests.cfg /data/GBProxy_Tests.cfg

ENTRYPOINT	["ttcn3-docker-run", "gbproxy", "GBProxy_Tests"]
