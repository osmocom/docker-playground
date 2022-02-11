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
		&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
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
COPY	.common/pipework	/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

WORKDIR	/data
CMD	["/docker-entrypoint.sh"]

EXPOSE	23000/udp 4246/tcp 4263/tcp
