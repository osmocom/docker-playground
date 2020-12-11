ARG	USER
FROM	$USER/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	make deps

RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout $OSMO_TTCN3_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_TTCN3_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	make gbproxy

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-dumpcap-stop.sh /

COPY	GBProxy_Tests.cfg /data/GBProxy_Tests.cfg
COPY	pipework /usr/bin/pipework
COPY	docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT	["/docker-entrypoint.sh"]
