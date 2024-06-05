ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libasn1c-dev \
			libsqlite3-dev \
			libosmo-abis-dev \
			libosmo-mgcp-client-dev \
			libosmo-gsup-client-dev \
			libosmo-netif-dev \
			libosmo-ranap-dev \
			libosmo-sigtran-dev \
			libosmocore-dev \
			libsmpp34-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libasn1c)" \
			"pkgconfig(libosmo-gsup-client)" \
			"pkgconfig(libosmo-mgcp-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-ranap)" \
			"pkgconfig(libosmo-sccp)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libsmpp34)" \
			sqlite-devel \
		;; \
	esac

WORKDIR	/tmp

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

ARG	OSMO_MSC_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-msc.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-msc/+/$OSMO_MSC_BRANCH?format=TEXT /tmp/commit-osmo-msc

RUN	cd osmo-msc && \
	git fetch && git checkout $OSMO_MSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_MSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make "-j$(nproc)" install


VOLUME	/data

COPY	osmo-msc.cfg /data/osmo-msc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-msc -c /data/osmo-msc.cfg >/data/osmo-msc.log 2>&1"]

#EXPOSE
