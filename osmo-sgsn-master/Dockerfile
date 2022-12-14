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
			telnet \
			libosmo-gsup-client-dev \
			libosmo-ranap-dev \
			libosmo-sigtran-dev \
			libgtp-dev \
			libasn1c-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libasn1c)" \
			"pkgconfig(libcrypto)" \
			"pkgconfig(libgtp)" \
			"pkgconfig(libosmo-gsup-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-ranap)" \
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
        && make -j8 \
        && make install \
        && make distclean && ldconfig

ARG     OSMO_GGSN_BRANCH="master"
RUN     git clone https://gerrit.osmocom.org/osmo-ggsn
ADD     https://gerrit.osmocom.org/plugins/gitiles/osmo-ggsn/+/$OSMO_GGSN_BRANCH?format=TEXT /tmp/commit-osmo-ggsn

RUN     cd osmo-ggsn \
        && git fetch && git checkout -f -B $OSMO_GGSN_BRANCH origin/$OSMO_GGSN_BRANCH \
        && git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
        && autoreconf -fi \
        && ./configure \
               --disable-doxygen \
               --prefix=/usr/local \
        && make -j8 \
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
        ./configure && \
        make "-j$(nproc)" install && \
        install examples/.libs/sccp_demo_user /usr/local/bin/ && \
        ldconfig

ARG	OSMO_SGSN_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-sgsn.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-sgsn/+/$OSMO_SGSN_BRANCH?format=TEXT /tmp/commit-osmo-sgsn

RUN	cd osmo-sgsn && \
	git fetch && git checkout $OSMO_SGSN_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_SGSN_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-iu && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-sgsn.cfg /data/osmo-sgsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-sgsn -c /data/osmo-sgsn.cfg >/data/osmo-sgsn.log 2>&1"]

EXPOSE	23000/udp 4245/tcp 4249/tcp 4246/tcp 4263/tcp
