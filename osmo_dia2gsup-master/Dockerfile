ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-erlang
# Arguments used after FROM must be specified again
ARG	DISTRO

WORKDIR	/tmp

ARG	OSMO_DIA2GSUP_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/erlang/osmo_dia2gsup.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/erlang/osmo_dia2gsup/+/$OSMO_DIA2GSUP_BRANCH?format=TEXT /tmp/commit-osmo_dia2gsup

RUN	cd osmo_dia2gsup && \
	git fetch && git checkout $OSMO_DIA2GSUP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_DIA2GSUP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	rebar3 compile && \
	rebar3 escriptize

VOLUME	/data

COPY	osmo_dia2gsup.config /data/osmo_dia2gsup.config

WORKDIR	/data
CMD	["/bin/sh", "-c", "ERL_FLAGS='-config /data/osmo_dia2gsup.config' /tmp/osmo_dia2gsup/_build/default/bin/osmo-dia2gsup > /data/osmo_dia2gsup.config.log 2>&1"]

#EXPOSE
