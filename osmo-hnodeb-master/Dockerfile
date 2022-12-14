ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libasn1c-dev && \
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

ARG	OSMO_HNODEB_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-hnodeb.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-hnodeb/+/$OSMO_HNODEB_BRANCH?format=TEXT /tmp/commit-osmo-hnodeb

RUN	cd osmo-hnodeb && \
	git fetch && git checkout $OSMO_HNODEB_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_HNODEB_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-sanitize && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnodeb.cfg /data/osmo-hnodeb.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-hnodeb -c /data/osmo-hnodeb.cfg >/data/osmo-hnodeb.log 2>&1"]
