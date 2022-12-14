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
		&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
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
ADD     https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH /tmp/commit-libosmocore

RUN     cd libosmocore \
        && git fetch && git checkout -f -B $LIBOSMOCORE_BRANCH origin/$LIBOSMOCORE_BRANCH?format=TEXT \
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

ARG	OSMO_GBPROXY_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-gbproxy.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-gbproxy/+/$OSMO_GBPROXY_BRANCH?format=TEXT /tmp/commit-osmo-gbproxy

RUN	cd osmo-gbproxy && \
	git fetch && git checkout $OSMO_GBPROXY_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_GBPROXY_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-sanitize && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-gbproxy.cfg 	/data/osmo-gbproxy.cfg

# work-around for stupid docker not being able to properly deal with host netdevices or start
# containers in pre-existing netns
COPY	.common/pipework	/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

WORKDIR	/data
CMD	["/docker-entrypoint.sh"]

EXPOSE	23000/udp 4246/tcp 4263/tcp
