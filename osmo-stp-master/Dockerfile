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
			telnet libosmo-abis-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/data

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
	&& make -j8 \
	&& make install \
	&& make distclean && ldconfig

ARG	OSMO_STP_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmo-sigtran.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-sigtran/+/$OSMO_STP_BRANCH?format=TEXT /tmp/commit-libosmo-sigtran

RUN	cd libosmo-sigtran && \
	git fetch && git checkout $OSMO_STP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_STP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	install examples/.libs/sccp_demo_user /usr/local/bin/ && \
	ldconfig

VOLUME	/data

COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
