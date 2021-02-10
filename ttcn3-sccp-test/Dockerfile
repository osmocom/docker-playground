ARG	USER
FROM	$USER/debian-stretch-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" sccp

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	SCCP_Tests.cfg /data/SCCP_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/sccp/SCCP_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh SCCP_Tests --rm; \
	exit $exit_code
