ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			osmo-mgw && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-mgw \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-mgw.cfg /data/osmo-mgw.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-mgw -c /data/osmo-mgw.cfg >/data/osmo-mgw.log 2>&1"]
