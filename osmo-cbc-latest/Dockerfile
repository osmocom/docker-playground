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
			osmo-cbc && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-cbc \
		;; \
	esac

WORKDIR	/data

VOLUME	/data
COPY	osmo-cbc.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-cbc -c /data/osmo-cbc.cfg >/data/osmo-cbc.log 2>&1"]

EXPOSE	12345 4264 48049
