ARG	USER
FROM	$USER/debian-bullseye-build


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

# Commit from 2021-08-24
RUN	git clone https://github.com/nplab/packetdrill && \
	cd packetdrill && \
	git checkout c6810864095558f5df77e9f06941191cbd41d7e2 && \
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
