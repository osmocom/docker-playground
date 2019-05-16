ARG	USER
FROM	$USER/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

RUN	cd osmo-ttcn3-hacks && \
	git checkout -f master && \
	make deps

RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout -f $OSMO_TTCN3_BRANCH && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	make sgsn

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	SGSN_Tests.cfg /data/SGSN_Tests.cfg

WORKDIR /data
ENTRYPOINT ["/osmo-ttcn3-hacks/start-testsuite.sh", "/osmo-ttcn3-hacks/sgsn/SGSN_Tests"]
