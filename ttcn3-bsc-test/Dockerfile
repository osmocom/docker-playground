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
	git checkout -f -B $OSMO_TTCN3_BRANCH origin/$OSMO_TTCN3_BRANCH && \
	make bsc

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	BSC_Tests.cfg /data/BSC_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/bsc/BSC_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh BSC_Tests --rm; \
	exit $exit_code
