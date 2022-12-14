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
			libosmo-netif-dev \
			libulfius-dev \
			libsctp-dev \
			gdb \
			&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libulfius)" \
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
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" \
        && ./configure \
                --disable-doxygen \
                --disable-pcsc \
                --prefix=/usr/local \
               --enable-libsctp \
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
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& ./configure \
		--disable-doxygen \
		--enable-libsctp \
		--prefix=/usr/local \
		--enable-sanitize \
	&& make -j8 \
	&& make install \
	&& make distclean && ldconfig

ARG     LIBOSMONETIF_BRANCH="master"
RUN     git clone https://gerrit.osmocom.org/libosmo-netif
ADD     https://gerrit.osmocom.org/plugins/gitiles/libosmo-netif/+/$LIBOSMONETIF_BRANCH?format=TEXT /tmp/commit-libosmonetif

RUN     cd libosmo-netif \
        && git fetch && git checkout -f -B $LIBOSMONETIF_BRANCH origin/$LIBOSMONETIF_BRANCH \
        && git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
        && autoreconf -fi \
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" \
        && ./configure \
               --disable-doxygen \
               --enable-libsctp \
               --prefix=/usr/local \
	       --enable-sanitize \
        && make -j8 \
        && make install \
        && make distclean && ldconfig

ARG	OSMO_CBC_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-cbc.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-cbc/+/$OSMO_CBC_BRANCH?format=TEXT /tmp/commit-osmo-cbc

RUN	cd osmo-cbc && \
	git fetch && git checkout $OSMO_CBC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_CBC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	./configure --enable-sanitize && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-cbc.cfg /data/osmo-cbc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-cbc -c /data/osmo-cbc.cfg >/data/osmo-cbc.log 2>&1"]

#EXPOSE
