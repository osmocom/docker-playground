ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" mgw

VOLUME	/data

COPY	MGCP_Test.cfg /data/MGCP_Test.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/mgw/MGCP_Test; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh MGCP_Test --rm; \
	exit $exit_code
