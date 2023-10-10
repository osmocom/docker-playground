ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bookworm-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends --no-install-suggests \
		libgnutls28-dev \
		&& \
	apt-get clean

ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" hss

VOLUME	/data

COPY	ogs/HSS_Tests.cfg /data/HSS_Tests.cfg

CMD	ttcn3-docker-run hss HSS_Tests
