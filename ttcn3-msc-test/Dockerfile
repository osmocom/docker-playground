FROM	laforge/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	make deps

RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout -f -B master origin/master && \
	git cherry-pick 5ce5241d6d460e9b36a908ac7072d8ea68df08db && \
	make msc

VOLUME	/data

COPY	MSC_Tests.cfg /data/MSC_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/msc/MSC_Tests && \
	ttcn3_logmerge MSC*.log
