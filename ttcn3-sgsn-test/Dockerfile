ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" sgsn

VOLUME	/data

COPY	SGSN_Tests.cfg /data/SGSN_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/sgsn/SGSN_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh SGSN_Tests --rm; \
	exit $exit_code
