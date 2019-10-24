ARG	USER
FROM	$USER/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

# FIXME: Once M3UA dep update patches in laforge/stp is merged into master, the
# line checking it out can be removed.
RUN	cd osmo-ttcn3-hacks && \
	git checkout -f -B master origin/master && \
	git fetch && git checkout -f -B laforge/stp origin/laforge/stp && \
	make deps

RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

# FIXME: Once STP patches in laforge/stp are merged into master, then
# OSMO_TTCN3_BRANCH can be set again to "master".
ARG	OSMO_TTCN3_BRANCH="laforge/stp"

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch?h=$OSMO_TTCN3_BRANCH /tmp/commit
RUN	cd osmo-ttcn3-hacks && \
	git fetch && \
	git checkout $OSMO_TTCN3_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_TTCN3_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	make stp

VOLUME	/data

RUN	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-start.sh / && \
	ln -s /osmo-ttcn3-hacks/ttcn3-tcpdump-stop.sh /

COPY	STP_Tests.cfg /data/STP_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/stp/STP_Tests; \
	exit_code=$?; \
	/osmo-ttcn3-hacks/log_merge.sh STP_Tests --rm; \
	exit $exit_code
