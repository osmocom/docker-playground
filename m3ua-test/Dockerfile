FROM laforge/sigtran-tests

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	cd /tmp && git clone https://github.com/nplab/m3ua-testtool
ADD	http://git.osmocom.org/nplab/m3ua-testtool/commit /tmp/commit
RUN	cd /tmp/m3ua-testtool && \
	git pull && \
	cc -o runm3uatest runm3uatest.c && \
	cp runm3uatest /usr/local/bin/

COPY	dotguile /root/.guile

RUN	mkdir /data

VOLUME	/data

COPY	m3ua-param-testtool.scm run-all-sgp-tests /data/

CMD	/data/run-all-sgp-tests
