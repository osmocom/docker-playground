ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-obs-latest
# Arguments used after FROM must be specified again

# Disable update-initramfs to save time during apt-get install
RUN	ln -s /bin/true /usr/local/bin/update-initramfs && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		bc \
		bison \
		bridge-utils \
		busybox-static \
		ca-certificates \
		flex \
		gcc \
		git \
		libc6-dev \
		libelf-dev \
		libssl-dev \
		linux-image-amd64 \
		make \
		osmo-ggsn \
		pax-utils \
		qemu-system-x86 && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-ggsn -c /data/osmo-ggsn.cfg >/data/osmo-ggsn.log 2>&1"]

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
