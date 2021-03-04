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
			libsofia-sip-ua-glib-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(sofia-sip-ua-glib)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_SIP_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-sip-connector.git
ADD	http://git.osmocom.org/osmo-sip-connector/patch?h=$OSMO_SIP_BRANCH /tmp/commit-osmo-sip-connector

RUN	cd osmo-sip-connector && \
	git fetch && git checkout $OSMO_SIP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_SIP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-sip-connector.cfg /data/osmo-sip-connector.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-sip-connector -c /data/osmo-sip-connector.cfg >/data/osmo-sip-connector.log 2>&1"]

#EXPOSE	
