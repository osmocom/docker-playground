ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		gdb \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-mgcp-client-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libosmo-ranap-dev \
		libosmo-rua-dev \
		libosmo-hnbap-dev \
		libasn1c-dev \
		libosmo-pfcp-dev \
		libosmo-mgcp-client-dev \
		&& \
	apt-get clean

WORKDIR	/tmp

# Download, build and install libosmocore
ARG	LIBOSMOCORE_BRANCH="master"
RUN	git clone https://gerrit.osmocom.org/libosmocore
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH?format=TEXT /tmp/commit-libosmocore

RUN	cd libosmocore \
	&& git fetch && git checkout -f -B $LIBOSMOCORE_BRANCH origin/$LIBOSMOCORE_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& autoreconf -fi \
	&& ./configure \
		--disable-doxygen \
		--disable-pcsc \
		--prefix=/usr/local \
		--enable-sanitize \
		--enable-libsctp \
	&& make -j5 \
	&& make install \
	&& make distclean && ldconfig

ARG	LIBOSMOABIS_BRANCH="master"
RUN	git clone https://gerrit.osmocom.org/libosmo-abis
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-abis/+/$LIBOSMOABIS_BRANCH?format=TEXT /tmp/commit-libosmoabis

RUN	cd libosmo-abis \
	&& git fetch && git checkout -f -B $LIBOSMOABIS_BRANCH origin/$LIBOSMOABIS_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& autoreconf -fi \
	&& ./configure \
		--disable-doxygen \
		--prefix=/usr/local \
		--enable-sanitize \
	&& make -j5 \
	&& make install \
	&& make distclean && ldconfig

ARG	LIBOSMONETIF_BRANCH="master"
RUN	git clone https://gerrit.osmocom.org/libosmo-netif
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-netif/+/$LIBOSMONETIF_BRANCH?format=TEXT /tmp/commit-libosmonetif

RUN	cd libosmo-netif \
	&& git fetch && git checkout -f -B $LIBOSMONETIF_BRANCH origin/$LIBOSMONETIF_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& autoreconf -fi \
	&& ./configure \
	       --disable-doxygen \
	       --prefix=/usr/local \
	       --enable-sanitize \
	       --enable-libsctp \
	&& make -j8 \
	&& make install \
	&& make distclean && ldconfig

ARG	OSMO_IUH_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-iuh.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-iuh/+/$OSMO_IUH_BRANCH?format=TEXT /tmp/commit-osmo-iuh

RUN	cd osmo-iuh && \
	git fetch && git checkout $OSMO_IUH_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_IUH_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

ARG	OSMO_MGW_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-mgw.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-mgw/+/$OSMO_MGW_BRANCH?format=TEXT /tmp/commit-osmo-mgw

RUN	cd osmo-mgw && \
	git fetch && git checkout $OSMO_MGW_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_MGW_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

ARG	OSMO_HNBGW_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-hnbgw.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-hnbgw/+/$OSMO_HNBGW_BRANCH?format=TEXT /tmp/commit-osmo-hnbgw

RUN	cd osmo-hnbgw && \
	git fetch && git checkout $OSMO_HNBGW_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_HNBGW_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-pfcp --enable-sanitize && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hnbgw -c /data/osmo-hnbgw.cfg >/data/osmo-hnbgw.log 2>&1"]
