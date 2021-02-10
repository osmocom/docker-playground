ARG	USER
FROM	$USER/debian-stretch-titan

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
	make bsc-nat

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	BSCNAT_Tests.cfg /data/BSCNAT_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/bsc-nat/BSCNAT_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh BSCNAT_Tests --rm; \
	exit $exit_code
