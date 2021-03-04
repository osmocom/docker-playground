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
			libosmo-gsup-client-dev \
			libosmo-netif-dev \
			libosmo-ranap-dev \
			libosmo-sccp-dev \
			libosmo-sigtran-dev \
			libsmpp34-dev \
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

ARG	OSMO_SGSN_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-sgsn.git
ADD	http://git.osmocom.org/osmo-sgsn/patch?h=$OSMO_SGSN_BRANCH /tmp/commit

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
