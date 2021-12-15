ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" remsim

VOLUME	/data

COPY	REMSIM_Tests.cfg /data/REMSIM_Tests.cfg

CMD	ttcn3-docker-run remsim REMSIM_Tests
