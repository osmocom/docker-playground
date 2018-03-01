ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" bts

VOLUME	/data

COPY	generic/BTS_Tests.cfg /data/BTS_Tests.cfg
COPY	Makefile.within-docker-img /Makefile

WORKDIR /
CMD	make test
