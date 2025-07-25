ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-erlang
# Arguments used after FROM must be specified again
ARG	DISTRO

# build and run the project as root
USER	root

WORKDIR	/tmp

ARG	OSMO_S1GW_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/erlang/osmo-s1gw.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/erlang/osmo-s1gw/+/$OSMO_S1GW_BRANCH?format=TEXT /tmp/commit-osmo-s1gw

RUN	cd osmo-s1gw && \
		git fetch && git checkout $OSMO_S1GW_BRANCH && \
		(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_S1GW_BRANCH || exit 1); \
		git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
		make && make install

VOLUME	/data

COPY	osmo-s1gw.config /data/osmo-s1gw.config

CMD	["/bin/sh", "-c", "osmo-s1gw -c /data/osmo-s1gw.config > /data/osmo-s1gw.log 2>&1"]
