ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-erlang
# Arguments used after FROM must be specified again
ARG	DISTRO

WORKDIR	/tmp

# erlang repo is using build user
USER root
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			osmo-epdg && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-epdg \
		;; \
	esac

WORKDIR	/data

VOLUME	/data
COPY	osmo-epdg.config /data/osmo-epdg.config

CMD	["/bin/sh", "-c", "ERL_FLAGS='-config /data/osmo-epdg.config' /usr/bin/osmo-epdg > /data/osmo-epdg.log 2>&1"]

#EXPOSE
