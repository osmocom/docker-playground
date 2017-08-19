FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	apt-get update && apt-get -y install		\
	guile-2.0 guile-2.0-dev gnulib tcsh

RUN	cd /tmp && git clone https://github.com/nplab/guile-sctp && \
	cd guile-sctp && \
	./bootstrap && \
	./configure && \
	make && \
	make install
