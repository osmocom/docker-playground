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
			osmo-remsim-server \
			osmo-remsim-client-shell \
			osmo-remsim-client-st2 \
			osmo-remsim-bankd && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-remsim-server \
			osmo-remsim-client-shell \
			osmo-remsim-client-st2 \
			osmo-remsim-bankd \
		;; \
	esac

#ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

VOLUME	/data

#COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-resmim-server >/data/osmo-resmim-server.log 2>&1"]

#EXPOSE
