# Proposed new Dockerfile for gerrit.osmocom.org build testing
# The idea is to have one image with all library dependencies of all
# projects, and then simply 'git pull' + build the given project
# that we want to compile-test at 'docker run' time (in tmpfs)

ARG	USER
FROM	$USER/debian-jessie-buildslave

MAINTAINER Harald Welte <laforge@gnumonks.org>

USER	build
WORKDIR	/build

# initial clone of all library repositories, i.e. repositories that we
# want to pull, compile and install during 'docker build' time of this
# image.  We crate a base checkout here that creates an intermediate
# cache layer.  Later we use the  "ADD http://git..." trick to ensure
# we re-fetch/re-build once master changes
RUN	git clone git://git.osmocom.org/libasn1c.git && \
	git clone git://git.osmocom.org/libsmpp34.git && \
	git clone git://git.osmocom.org/libosmocore.git && \
	git clone git://git.osmocom.org/libosmo-abis.git && \
	git clone git://git.osmocom.org/libosmo-netif.git && \
	git clone git://git.osmocom.org/libosmo-sccp.git && \
	git clone git://git.osmocom.org/osmo-iuh.git && \
	git clone git://git.osmocom.org/osmo-mgw.git

# initial checkout of all applications-under-test to avoid full
# re-clone at every build.  We intentionally don't have "ADD"
# statements to cgit URLs, so the cache will not detect and rebuild
# if the upstream repo changes.  This is no problem, as at 'run' time
# we'll be doing a git fetch anyway.
RUN	git clone --reference osmo-mgw git://git.osmocom.org/openbsc.git && \
	git clone --reference openbsc git://git.osmocom.org/osmo-bsc.git && \
	git clone --reference openbsc git://git.osmocom.org/osmo-msc.git && \
	git clone --reference openbsc git://git.osmocom.org/osmo-sgsn.git && \
	git clone git://git.osmocom.org/openggsn.git && \
	git clone --reference openggsn git://git.osmocom.org/osmo-ggsn.git && \
	git clone git://git.osmocom.org/osmo-bts.git && \
	git clone git://git.osmocom.org/osmo-hlr.git && \
	git clone git://git.osmocom.org/osmo-pcu.git && \
	git clone git://git.osmocom.org/osmo-sip-connector.git && \
	git clone git://git.osmocom.org/osmo-trx.git

# build libasn1c first, no libosmo* dependency and infrequent changes
ADD	http://git.osmocom.org/libasn1c/patch /tmp/commit-libasn1c
RUN	cd libasn1c && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

# build libsmpp34 first, no libosmo* dependency and infrequent changes
ADD	http://git.osmocom.org/libsmpp34/patch /tmp/commit-libsmpp34
RUN	cd libsmpp34 && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

# build libosmocore before any of its downatream dependences
ADD	http://git.osmocom.org/libosmocore/patch /tmp/commit-libosmocore
RUN	cd libosmocore && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

# now build all of the downstream dependencies of libosmocore

ADD	http://git.osmocom.org/libosmo-abis/patch /tmp/commit-libosmo-abis
RUN	cd libosmo-abis && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

ADD	http://git.osmocom.org/libosmo-netif/patch /tmp/commit-libosmo-netif
RUN	cd libosmo-netif && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

ADD	http://git.osmocom.org/libosmo-sccp/patch /tmp/commit-libosmo-sccp
RUN	cd libosmo-sccp && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

ADD	http://git.osmocom.org/osmo-mgw/patch /tmp/commit-osmo-mgw
RUN	cd osmo-mgw && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

ADD	http://git.osmocom.org/osmo-iuh/patch /tmp/commit-osmo-iuh
RUN	cd osmo-iuh && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig

ADD	http://git.osmocom.org/osmo-ggsn/patch /tmp/commit-osmo-ggsn
RUN	cd osmo-ggsn && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" && \
	sudo make install && \
	make clean && \
	sudo ldconfig


# example command which builds a single osmo-* application at 'docker run' time in tmpfs
CMD	/bin/sh -c 'cd /tmpfs && git clone --reference /build/openbsc git://git.osmocom.org/openbsc.git && cd openbsc && git checkout -f -B master origin/master && cd openbsc && autoreconf -fi && ./configure --enable-nat --enable-osmo-bsc --enable-smpp --enable-vty-tests --enable-external-tests && make "-j$(nproc)" check'
