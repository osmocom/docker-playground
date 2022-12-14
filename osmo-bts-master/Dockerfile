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
			gdb && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocodec)" \
			"pkgconfig(libosmocoding)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmotrau)" \
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
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" \
        && ./configure \
                --disable-doxygen \
                --disable-pcsc \
                --prefix=/usr/local --enable-sanitize \
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
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& ./configure \
		--disable-doxygen \
		--prefix=/usr/local \
		--enable-libsctp --enable-sanitize \
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
		--prefix=/usr/local --enable-sanitize \
	&& make -j5 \
	&& make install \
	&& make distclean && ldconfig

ARG	OSMO_BTS_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-bts.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-bts/+/$OSMO_BTS_BRANCH?format=TEXT /tmp/commit-osmo-bts

RUN	cd osmo-bts && \
	git fetch && git checkout $OSMO_BTS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BTS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	export CFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	./configure --enable-trx --enable-sanitize && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
	# send GSMTAP data to .230 which is the ttcn3-sysinfo test
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bts-virtual -c /data/osmo-bts.cfg -i 172.18.0.230 >>/data/osmo-bts-virtual.log 2>&1"]

#EXPOSE
