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
			osmo-stp && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-stp \
		;; \
	esac

WORKDIR	/data

VOLUME	/data
COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
