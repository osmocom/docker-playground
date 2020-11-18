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
			libosmo-netif-dev \
			libosmo-sccp-dev \
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
			"pkgconfig(libosmotrau)" \
			"pkgconfig(libosmovty)" \
			telnet \
		;; \
	esac

ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

ARG	OSMO_BTS_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-bts.git
ADD	http://git.osmocom.org/osmo-bts/patch?h=$OSMO_BTS_BRANCH /tmp/commit-osmo-bts

RUN	cd osmo-bts && \
	git fetch && git checkout $OSMO_BTS_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BTS_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-trx && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
	# send GSMTAP data to .230 which is the ttcn3-sysinfo test
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bts-virtual -c /data/osmo-bts.cfg -i 172.18.0.230 >>/data/osmo-bts-virtual.log 2>&1"]

#EXPOSE
