ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libosmocore-dev \
			libgtpnl-dev \
			libnftables-dev \
			libosmo-pfcp-dev \
		&& apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libgtpnl)" \
			"pkgconfig(libnftables)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libosmo-pfcp)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_UPF_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/osmo-upf.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-upf/+/$OSMO_UPF_BRANCH?format=TEXT /tmp/commit-osmo-upf

RUN	cd osmo-upf && \
	git fetch && git checkout $OSMO_UPF_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_UPF_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-upf.cfg /data/osmo-upf.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-upf -c /data/osmo-upf.cfg >/data/osmo-upf.log 2>&1"]

#EXPOSE
