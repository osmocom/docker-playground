FROM	laforge/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	make deps

ARG	OSMO_TTCN3_BRANCH="master"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout -f -B $OSMO_TTCN3_BRANCH origin/$OSMO_TTCN3_BRANCH && \
	make sysinfo

VOLUME	/data

COPY	Test.cfg /data/Test.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/sysinfo/Test; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh Test --rm; \
	exit $exit_code
