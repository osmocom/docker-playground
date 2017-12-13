FROM	laforge/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	make mgw

VOLUME	/data

COPY	MGCP_Test.cfg /data/MGCP_Test.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/mgw/MGCP_Test && \
	ttcn3_logmerge MGCP*.log
