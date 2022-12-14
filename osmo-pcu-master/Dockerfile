ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libosmocore-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libosmoctrl)" \
		;; \
	esac

WORKDIR	/tmp

# Download, build and install libosmocore
ARG	LIBOSMOCORE_BRANCH="master"
RUN	git clone https://gerrit.osmocom.org/libosmocore
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH?format=TEXT /tmp/commit-libosmocore

RUN	cd libosmocore \
	&& git fetch && git checkout -f -B $LIBOSMOCORE_BRANCH origin/$LIBOSMOCORE_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" \
	&& autoreconf -fi \
	&& ./configure \
		--disable-doxygen \
		--disable-pcsc \
		--enable-force-io-select \
		--prefix=/usr/local --enable-sanitize \
	&& make -j5 \
	&& make install \
	&& make distclean && ldconfig

ARG	OSMO_PCU_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-pcu.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-pcu/+/$OSMO_PCU_BRANCH?format=TEXT /tmp/commit-osmo-pcu

RUN	cd osmo-pcu && \
	git fetch && git checkout $OSMO_PCU_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_PCU_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" && \
	autoreconf -fi && \
	./configure  --enable-sanitize  && \
	make "-j$(nproc)" V=1 install

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-pcu", "-i", "172.18.0.230"]

#EXPOSE
