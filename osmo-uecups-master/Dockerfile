ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libjansson-dev \
		libnl-route-3-dev \
		libosmocore-dev \
		libosmo-netif-dev \
		libsctp-dev \
		iputils-ping \
		gdb \
		strace && \
	apt-get clean

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
        && ./configure \
               --disable-doxygen \
               --prefix=/usr/local \
        && make -j8 \
        && make install \
        && make distclean && ldconfig

ARG	OSMO_UECUPS_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-uecups.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-uecups/+/$OSMO_UECUPS_BRANCH?format=TEXT /tmp/commit-osmo-uecups

RUN	cd osmo-uecups && \
	git fetch && git checkout $OSMO_UECUPS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_UECUPS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-uecups-daemon.cfg /data/osmo-uecups-daemon.cfg

RUN	usermod -l osmocom build

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-uecups-daemon -c /data/osmo-uecups-daemon.cfg >/data/osmo-uecups-daemon.log 2>&1"]

#EXPOSE
