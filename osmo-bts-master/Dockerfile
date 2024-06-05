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
			libsmpp34-dev \
			libgtp-dev && \
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

ARG	OSMO_BTS_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-bts.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-bts/+/$OSMO_BTS_BRANCH?format=TEXT /tmp/commit-osmo-bts

RUN	cd osmo-bts && \
	git fetch && git checkout $OSMO_BTS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BTS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-trx && \
	make "-j$(nproc)" install

ARG     LIBOSMOCORE_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmocore.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH?format=TEXT /tmp/commit-libosmocore
RUN     cd libosmocore && \
        git fetch && git checkout $LIBOSMOCORE_BRANCH && \
        (git symbolic-ref -q HEAD && git reset --hard origin/$LIBOSMOCORE_BRANCH || exit 1); \
        git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
        autoreconf -fi && \
        ./configure && \
        make "-j$(nproc)" install && \
        ldconfig

ARG     LIBOSMOABIS_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmo-abis.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-abis/+/$LIBOSMOABIS_BRANCH?format=TEXT /tmp/commit-libosmoabis
RUN     cd libosmo-abis && \
        git fetch && git checkout $LIBOSMOABIS_BRANCH && \
        (git symbolic-ref -q HEAD && git reset --hard origin/$LIBOSMOABIS_BRANCH || exit 1); \
        git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
        autoreconf -fi && \
        ./configure && \
        make "-j$(nproc)" install && \
        ldconfig

ARG     LIBOSMONETIF_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmo-netif.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-netif/+/$LIBOSMONETIF_BRANCH?format=TEXT /tmp/commit-libosmonetif
RUN     cd libosmo-netif && \
        git fetch && git checkout $LIBOSMONETIF_BRANCH && \
        (git symbolic-ref -q HEAD && git reset --hard origin/$LIBOSMONETIF_BRANCH || exit 1); \
        git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
        autoreconf -fi && \
        ./configure && \
        make "-j$(nproc)" install && \
        ldconfig

ARG     OSMO_STP_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmo-sccp.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-sccp/+/$OSMO_STP_BRANCH?format=TEXT /tmp/commit-libosmosccp
RUN     cd libosmo-sccp && \
        git fetch && git checkout $OSMO_STP_BRANCH && \
        (git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_STP_BRANCH || exit 1); \
        git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
        autoreconf -fi && \
        ./configure && \
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

COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
	# send GSMTAP data to .230 which is the ttcn3-sysinfo test
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bts-virtual -c /data/osmo-bts.cfg -i 172.18.0.230 >>/data/osmo-bts-virtual.log 2>&1"]

#EXPOSE
