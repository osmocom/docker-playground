FROM laforge/sigtran-tests

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	cd /tmp && git clone git://git.osmocom.org/nplab/m3ua-testtool
ADD	http://git.osmocom.org/nplab/m3ua-testtool/patch /tmp/commit
RUN	cd /tmp/m3ua-testtool && \
	git pull && \
	cp runtest-junitxml.py /usr/local/bin/

COPY	dotguile /root/.guile

RUN	mkdir /data

VOLUME	/data

COPY	m3ua-param-testtool.scm all-sgp-tests.txt /data/

CMD	/usr/local/bin/runtest-junitxml.py -s 0.1 -t 10 -d /root /data/all-sgp-tests.txt
