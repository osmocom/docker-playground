ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan
ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" pcap-client

VOLUME	/data

COPY	OPCAP_CLIENT_Tests.cfg /data/OPCAP_CLIENT_Tests.cfg

CMD	ttcn3-docker-run pcap-client OPCAP_CLIENT_Tests
