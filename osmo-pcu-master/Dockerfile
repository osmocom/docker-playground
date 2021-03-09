ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libosmocore-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libosmoctrl)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_PCU_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-pcu.git
ADD	http://git.osmocom.org/osmo-pcu/patch?h=$OSMO_PCU_BRANCH /tmp/commit-osmo-pcu

RUN	cd osmo-pcu && \
	git fetch && git checkout $OSMO_PCU_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_PCU_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-pcu", "-i", "172.18.0.230"]

#EXPOSE
