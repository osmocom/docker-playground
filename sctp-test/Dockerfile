FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		bison \
		flex && \
	apt-get clean

COPY *.patch /tmp/

RUN	git config --global user.email "nobody@localhost" && \
	git config --global user.name "Docker Container"

WORKDIR	/tmp

# Commit from 2018-08-28
RUN	git clone https://github.com/nplab/packetdrill && \
	cd packetdrill && \
	git checkout 89bb4f35393187d0d34a84170de529d688421be7 && \
	git am /tmp/*.patch && \
	cd gtests/net/packetdrill && \
	./configure && \
	make && \
	cp packetdrill /usr/bin/

# Commit from 2018-06-03
RUN	git clone https://github.com/nplab/ETSI-SCTP-Conformance-Testsuite.git && \
	cd "ETSI-SCTP-Conformance-Testsuite" && \
	git checkout 24768461f9b9be36a2a5e4b767c7afb749e3243f

COPY	run /tmp/run

CMD	/tmp/run
