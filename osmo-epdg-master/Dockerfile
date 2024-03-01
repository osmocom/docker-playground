ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-erlang
# Arguments used after FROM must be specified again
ARG	DISTRO

# $distro-erlang switched to user build, but we need to install more stuff beforehand:
USER	root
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		iproute2 && \
	apt-get clean
USER	build

WORKDIR	/tmp

ARG	OSMO_EPDG_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/erlang/osmo-epdg.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/erlang/osmo-epdg/+/$OSMO_EPDG_BRANCH?format=TEXT /tmp/commit-osmo-epdg

RUN	cd osmo-epdg && \
	git fetch && git checkout $OSMO_EPDG_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_EPDG_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	rm -f rebar.lock && \
	rebar3 compile && \
	rebar3 escriptize

VOLUME	/data

COPY	osmo-epdg.config /data/osmo-epdg.config

WORKDIR	/data
CMD	["/bin/sh", "-c", "ERL_FLAGS='-config /data/osmo-epdg.config' /tmp/osmo-epdg/_build/default/bin/osmo-epdg > /data/osmo-epdg.log 2>&1"]

#EXPOSE
