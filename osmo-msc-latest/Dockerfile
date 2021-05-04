ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again
ARG	DISTRO

# libdbi-dbd-sqlite can be removed after osmo-msc > 1.7.0 release
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			osmo-msc && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			libdbi-dbd-sqlite \
			osmo-msc \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-msc.cfg /data/osmo-msc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-msc -c /data/osmo-msc.cfg >/data/osmo-msc.log 2>&1"]

#EXPOSE
