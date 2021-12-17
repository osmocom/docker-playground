ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

# Disable update-initramfs to save time during apt-get install
RUN	case "$DISTRO" in \
	debian*) \
		ln -s /bin/true /usr/local/bin/update-initramfs && \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			bc \
			bridge-utils \
			busybox-static \
			ca-certificates \
			iproute2 \
			libelf-dev \
			libgtpnl-dev \
			libosmocore-dev \
			linux-image-amd64 \
			pax-utils \
			qemu-system-x86 && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libgtpnl)" \
			"pkgconfig(libmnl)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

ARG	OSMO_GGSN_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-ggsn.git
ADD	http://git.osmocom.org/osmo-ggsn/patch/?h=$OSMO_GGSN_BRANCH /tmp/commit
RUN	cd osmo-ggsn && \
	git fetch && git checkout $OSMO_GGSN_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_GGSN_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-gtp-linux && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-ggsn -c /data/osmo-ggsn.cfg >/data/osmo-ggsn.log 2>&1"]

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
