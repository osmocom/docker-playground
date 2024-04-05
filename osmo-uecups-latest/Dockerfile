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
			iputils-ping \
			osmo-uecups && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-uecups \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-uecups-daemon.cfg /data/osmo-uecups-daemon.cfg

RUN	useradd -m osmocom

WORKDIR /data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-uecups-daemon -c /data/osmo-uecups-daemon.cfg >/data/osmo-uecups-daemon.log 2>&1"]

#EXPOSE
