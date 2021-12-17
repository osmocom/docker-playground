ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again
ARG	DISTRO

# Install additional debian depends for kernel module test (OS#3208)
# Disable update-initramfs to save time during apt-get install
RUN	case "$DISTRO" in \
	debian*) \
		ln -s /bin/true /usr/local/bin/update-initramfs && \
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
			iproute2 \
			libc6-dev \
			libelf-dev \
			libssl-dev \
			linux-image-amd64 \
			make \
			osmo-ggsn \
			pax-utils \
			qemu-system-x86 && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			osmo-ggsn \
		;; \
	esac

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-ggsn -c /data/osmo-ggsn.cfg >/data/osmo-ggsn.log 2>&1"]

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
