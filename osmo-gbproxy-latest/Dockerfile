ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			osmo-gbproxy \
		&& \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-gbproxy \
		;; \
	*) \
		echo "Unsupported distribution $DISTRO" \
		exit 23 \
		;; \
	esac

WORKDIR	/data

VOLUME	/data

COPY	osmo-gbproxy.cfg 	/data/osmo-gbproxy.cfg

# work-around for stupid docker not being able to properly deal with host netdevices or start
# containers in pre-existing netns
COPY	.common/pipework	/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

CMD	["/docker-entrypoint.sh"]

EXPOSE	23000/udp 4246/tcp 4263/tcp
