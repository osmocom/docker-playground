ARG USER=osmocom-build
FROM $USER/sigtran-tests


RUN	cd /tmp && git clone https://git.osmocom.org/nplab/sua-testtool
ADD	http://git.osmocom.org/nplab/sua-testtool/patch/?h=laforge/python3 /tmp/commit
RUN	cd /tmp/sua-testtool && \
	git fetch && \
	git checkout -f laforge/python3 && \
	cp runtest-junitxml.py /usr/local/bin/

COPY	dotguile /root/.guile
COPY	.common/tcpdump-start.sh /usr/local/bin/tcpdump-start.sh
COPY	.common/tcpdump-stop.sh /usr/local/bin/tcpdump-stop.sh
COPY	test.sh /usr/local/bin/test.sh

RUN	mkdir /data

VOLUME	/data

COPY	sua-param-testtool-sgp.scm some-sua-sgp-tests.txt /data/

CMD	/usr/local/bin/runtest-junitxml.py -s 0.1 -t 10 -d /root /data/some-sua-sgp-tests.txt
