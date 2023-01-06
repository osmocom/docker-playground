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
			libosmo-netif-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/data

ARG	OSMO_STP_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmo-sccp.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmo-sccp/+/$OSMO_STP_BRANCH?format=TEXT /tmp/commit-libosmo-sccp

RUN	cd libosmo-sccp && \
	git fetch && git checkout $OSMO_STP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_STP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	install examples/.libs/sccp_demo_user /usr/local/bin/ && \
	ldconfig

VOLUME	/data

COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
