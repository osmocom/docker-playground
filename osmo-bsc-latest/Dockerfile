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
			osmo-bsc \
			osmo-bsc-ipaccess-utils && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-bsc \
			osmo-bsc-ipaccess-utils \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-bsc.cfg /data/osmo-bsc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-bsc -c /data/osmo-bsc.cfg >/data/osmo-bsc.log 2>&1"]

EXPOSE	3003 3002 4242
