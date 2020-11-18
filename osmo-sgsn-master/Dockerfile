ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	case "$DISTRO" in \
	debian*) \
		apt-key add /tmp/Release.key && \
		rm /tmp/Release.key && \
		echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list \
		;; \
	esac

# we need to add this to invalidate the cache once the repository is updated.
# unfortunately Dockerfiles don't support a conditional ARG, so we need to add both DPKG + RPM
ADD	$OSMOCOM_REPO/Release /tmp/Release
ADD	$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/nightly/CentOS_8_Stream/repodata/repomd.xml /tmp/repomd.xml
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			telnet \
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
			telnet \
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
