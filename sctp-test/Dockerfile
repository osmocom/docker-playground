FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		bison \
		flex && \
	apt-get clean

COPY *.patch /tmp/

RUN	git config --global user.email "nobody@localhost" && \
	git config --global user.name "Docker Container"

WORKDIR	/tmp

RUN	git clone https://github.com/nplab/packetdrill && \
	cd packetdrill && \
	git am /tmp/*.patch && \
	cd gtests/net/packetdrill && \
	./configure && \
	make && \
	cp packetdrill /usr/bin/

RUN	git clone https://github.com/nplab/ETSI-SCTP-Conformance-Testsuite.git

COPY	run /tmp/run

CMD	/tmp/run
