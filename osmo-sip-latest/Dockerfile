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
			osmo-sip-connector && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-sip-connector \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-sip-connector.cfg /data/osmo-sip-connector.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-sip-connector -c /data/osmo-sip-connector.cfg >/data/osmo-sip-connector.log 2>&1"]

#EXPOSE
