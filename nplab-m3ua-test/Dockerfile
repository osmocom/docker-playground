ARG USER=osmocom-build
FROM $USER/sigtran-tests

ARG	M3UA_TESTTOOL_BRANCH="osmocom/master"

RUN	cd /tmp && git clone https://gitea.osmocom.org/nplab/m3ua-testtool
ADD	https://gitea.osmocom.org/api/v1/repos/nplab/m3ua-testtool/git/refs/heads/$M3UA_TESTTOOL_BRANCH?format=TEXT /tmp/commit
RUN	cd /tmp/m3ua-testtool && \
	git fetch && git checkout $M3UA_TESTTOOL_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$M3UA_TESTTOOL_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	cp runtest-junitxml.py /usr/local/bin/

COPY	dotguile /root/.guile
COPY	.common/tcpdump-start.sh /usr/local/bin/tcpdump-start.sh
COPY	.common/tcpdump-stop.sh /usr/local/bin/tcpdump-stop.sh
COPY	test.sh /usr/local/bin/test.sh

RUN	mkdir /data

VOLUME	/data

COPY	m3ua-param-testtool.scm all-sgp-tests.txt /data/

CMD	/usr/local/bin/runtest-junitxml.py -s 0.1 -t 10 -d /root /data/all-sgp-tests.txt
