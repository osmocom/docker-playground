ARG	REGISTRY
ARG	USER
FROM	$REGISTRY/$USER/debian-bullseye-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends --no-install-suggests \
		libgnutls28-dev \
		&& \
	apt-get clean

ARG	OSMO_TTCN3_BRANCH="master"

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/$OSMO_TTCN3_BRANCH?format=TEXT /tmp/commit
RUN	ttcn3-docker-prepare "$OSMO_TTCN3_BRANCH" mme

VOLUME	/data

COPY	ogs/MME_Tests.cfg /data/MME_Tests.cfg

CMD	ttcn3-docker-run mme MME_Tests
