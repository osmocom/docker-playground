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
			libdbd-sqlite3 \
			osmo-hlr && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-hlr \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-hlr.cfg /data/osmo-hlr.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-hlr -c /data/osmo-hlr.cfg >/data/osmo-hlr.log 2>&1"]

EXPOSE	4222 4258 4259
