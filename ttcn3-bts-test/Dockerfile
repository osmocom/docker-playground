ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" bts

VOLUME	/data

COPY	BTS_Tests.cfg /data/BTS_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/bts/BTS_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh BTS_Tests --rm; \
	exit $exit_code
