ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" bsc-nat

VOLUME	/data

COPY	BSCNAT_Tests.cfg /data/BSCNAT_Tests.cfg

CMD	ttcn3-docker-run bsc-nat BSCNAT_Tests
