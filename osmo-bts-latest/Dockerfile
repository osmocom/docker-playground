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
			osmo-bts-trx \
			osmo-bts-virtual && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-bts \
			osmo-bts-virtual \
			osmo-bts-omldummy \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
	# send GSMTAP data to .230 which is the ttcn3-sysinfo test
CMD	["/bin/sh", "-c", "/usr/bin/osmo-bts-virtual -c /data/osmo-bts.cfg -i 172.18.0.230 >>/data/osmo-bts-virtual.log 2>&1"]

#EXPOSE
