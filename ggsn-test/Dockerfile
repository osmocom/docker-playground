FROM	laforge/debian-stretch-titan

RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	make deps

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout -f -B master origin/master && \
	make ggsn_tests

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	GGSN_Tests.cfg /data/GGSN_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/ggsn_tests/GGSN_Tests && \
	ttcn3_logmerge GGSN*.log
