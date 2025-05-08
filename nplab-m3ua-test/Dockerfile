ARG USER=osmocom-build
FROM $USER/sigtran-tests

RUN	cd /tmp && git clone https://gitea.osmocom.org/nplab/m3ua-testtool
ADD	https://gitea.osmocom.org/api/v1/repos/nplab/m3ua-testtool/git/refs/heads/laforge/python3 /tmp/commit
RUN	cd /tmp/m3ua-testtool && \
	git fetch && \
	git checkout -f laforge/python3 && \
	cp runtest-junitxml.py /usr/local/bin/

COPY	dotguile /root/.guile
COPY	.common/tcpdump-start.sh /usr/local/bin/tcpdump-start.sh
COPY	.common/tcpdump-stop.sh /usr/local/bin/tcpdump-stop.sh
COPY	test.sh /usr/local/bin/test.sh

RUN	mkdir /data

VOLUME	/data

COPY	m3ua-param-testtool.scm all-sgp-tests.txt /data/

CMD	/usr/local/bin/runtest-junitxml.py -s 0.1 -t 10 -d /root /data/all-sgp-tests.txt
