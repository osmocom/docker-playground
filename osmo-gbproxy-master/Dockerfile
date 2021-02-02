ARG	USER
ARG	DISTRO
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
ADD	$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/nightly/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			telnet \
			libosmocore-dev \
			libosmo-abis-dev \
			libosmo-netif-dev \
		&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			telnet \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			;; \
	esac

WORKDIR	/tmp

ARG	OSMO_GBPROXY_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-gbproxy.git
ADD	http://git.osmocom.org/osmo-gbproxy/patch?h=$OSMO_GBPROXY_BRANCH /tmp/commit

RUN	cd osmo-gbproxy && \
	git fetch && git checkout $OSMO_GBPROXY_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_GBPROXY_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-gbproxy.cfg 	/data/osmo-gbproxy.cfg

# work-around for stupid docker not being able to properly deal with host netdevices or start
# containers in pre-existing netns
COPY	pipework		/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

WORKDIR	/data
CMD	["/docker-entrypoint.sh"]

EXPOSE	23000/udp 4246/tcp 4263/tcp
