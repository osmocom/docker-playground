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
			osmo-pcap-client osmo-pcap-server && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-pcap \
		;; \
	esac

WORKDIR	/data

VOLUME	/data
COPY	osmo-pcap-client.cfg /data/
#COPY	osmo-pcap-server.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-pcap-client -c /data/osmo-pcap-client.cfg >/data/osmo-pcap-client.log 2>&1"]

EXPOSE	4237
