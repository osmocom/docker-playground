FROM laforge/sigtran-tests

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	*.patch /tmp/

RUN	git config --global user.email "nobody@localhost" && \
	git config --global user.name "Docker Container"

RUN	cd /tmp && git clone https://github.com/nplab/sua-testtool
ADD	http://git.osmocom.org/nplab/sua-testtool/patch /tmp/commit
RUN	cd /tmp/sua-testtool && \
	git pull && \
	git am /tmp/*.patch && \
	cc -o run-sua-test run-sua-test.c && \
	cp run-sua-test /usr/local/bin/

COPY	dotguile /root/.guile

RUN	mkdir /data

VOLUME	/data

COPY	sua-param-testtool-sgp.scm run-some-sua-sgp-tests /data/

CMD	/data/run-some-sua-sgp-tests
