FROM neels/debian-sid-build


WORKDIR	/build

ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-dev/+/master?format=TEXT /build/commit-osmo-dev
RUN	git clone https://gerrit.osmocom.org/osmo-dev.git

RUN	cd osmo-dev && \
	./gen_makefile.py 3G+2G.deps default.opts iu.opts -m make --ldconfig-without-sudo

# Not using gitiles plugin here because gen_makefile.py clones from git.osmocom.org
ADD	http://git.osmocom.org/libosmocore/patch /build/commit-libosmocore
ADD	http://git.osmocom.org/libosmo-abis/patch /build/commit-libosmo-abis
ADD	http://git.osmocom.org/libosmo-netif/patch /build/commit-libosmo-netif
ADD	http://git.osmocom.org/libosmo-sigtran/patch /build/commit-libosmo-sigtran
ADD	http://git.osmocom.org/libsmpp34/patch /build/commit-libsmpp34
ADD	http://git.osmocom.org/libasn1c/patch /build/commit-libasn1c
ADD	http://git.osmocom.org/osmo-ggsn/patch /build/commit-osmo-ggsn
ADD	http://git.osmocom.org/osmo-iuh/patch /build/commit-osmo-iuh
ADD	http://git.osmocom.org/osmo-hlr/patch /build/commit-osmo-hlr
ADD	http://git.osmocom.org/osmo-mgw/patch /build/commit-osmo-mgw
ADD	http://git.osmocom.org/osmo-msc/patch /build/commit-osmo-msc
ADD	http://git.osmocom.org/osmo-bsc/patch /build/commit-osmo-bsc
ADD	http://git.osmocom.org/osmo-sgsn/patch /build/commit-osmo-sgsn

WORKDIR /build/osmo-dev/make
RUN	make

COPY	cfg /cfg

WORKDIR	/cfg
CMD	["/usr/local/bin/osmo-msc", "-c", "/cfg/osmo-msc.cfg"]
