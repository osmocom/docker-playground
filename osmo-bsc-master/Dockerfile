ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libosmocore-dev \
			libosmo-abis-dev \
			libosmo-netif-dev \
			libosmo-sigtran-dev \
			libosmo-mgcp-client-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-mgcp-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

# Download, build and install libosmocore
ARG     LIBOSMOCORE_BRANCH="master"
RUN     git clone https://gerrit.osmocom.org/libosmocore
ADD     https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH?format=TEXT /tmp/commit-libosmocore

RUN     cd libosmocore \
        && git fetch && git checkout -f -B $LIBOSMOCORE_BRANCH origin/$LIBOSMOCORE_BRANCH \
        && git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
        && autoreconf -fi \
        && ./configure \
                --disable-doxygen \
                --disable-pcsc \
                --prefix=/usr/local \
                --enable-sanitize \
        && make -j5 \
        && make install \
        && make distclean && ldconfig

ARG     LIBOSMONETIF_BRANCH="master"
RUN     git clone https://gerrit.osmocom.org/libosmo-netif
ADD     https://gerrit.osmocom.org/plugins/gitiles/libosmo-netif/+/$LIBOSMONETIF_BRANCH?format=TEXT /tmp/commit-libosmonetif

RUN     cd libosmo-netif \
	&& git fetch && git checkout -f -B $LIBOSMONETIF_BRANCH origin/$LIBOSMONETIF_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& autoreconf -fi \
	&& ./configure \
		--disable-doxygen \
		--prefix=/usr/local \
		--enable-sanitize \
	&& make -j8 \
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

ARG     OSMO_STP_BRANCH="master"

RUN     git clone https://gerrit.osmocom.org/libosmo-sigtran.git
ADD     https://gerrit.osmocom.org/plugins/gitiles/libosmo-sigtran/+/$OSMO_STP_BRANCH?format=TEXT /tmp/commit
RUN     cd libosmo-sigtran && \
        git fetch && git checkout $OSMO_STP_BRANCH && \
        (git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_STP_BRANCH || exit 1); \
        git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
        autoreconf -fi && \
        ./configure --enable-sanitize && \
        make "-j$(nproc)" install && \
        install examples/.libs/sccp_demo_user /usr/local/bin/ && \
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

ARG	OSMO_BSC_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-bsc.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-bsc/+/$OSMO_BSC_BRANCH?format=TEXT /tmp/commit-osmo-bsc

RUN	cd osmo-bsc && \
	git fetch && git checkout $OSMO_BSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure  --enable-sanitize && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-bsc.cfg /data/osmo-bsc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bsc -c /data/osmo-bsc.cfg >/data/osmo-bsc.log 2>&1"]

#EXPOSE
