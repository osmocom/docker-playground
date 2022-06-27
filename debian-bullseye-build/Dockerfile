ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bullseye
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/${OSMOCOM_REPO_PATH}/nightly/Debian_11/"

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		autoconf \
		autoconf-archive \
		autogen \
		automake \
		bison \
		build-essential \
		ca-certificates \
		cppcheck \
		dahdi-source \
		debhelper \
		devscripts \
		dh-autoreconf \
		doxygen \
		equivs \
		flex \
		g++ \
		gawk \
		gcc \
		gcc-arm-none-eabi \
		git \
		git-buildpackage \
		gnupg \
		libc-ares-dev \
		libdbd-sqlite3 \
		libdbi-dev \
		libfftw3-dev \
		libgnutls28-dev \
		libgps-dev \
		libgsm1-dev \
		libmnl-dev \
		libncurses5-dev \
		libnewlib-arm-none-eabi \
		libortp-dev \
		libpcap-dev \
		libpcsclite-dev \
		libtalloc-dev \
		libtool \
		libreadline-dev \
		libsctp-dev \
		libsofia-sip-ua-glib-dev \
		libsqlite3-dev \
		libssl-dev \
		libusb-dev \
		libusb-1.0-0-dev \
		make \
		pkg-config \
		sqlite3 \
		stow \
		telnet \
		wget && \
	apt-get clean

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

COPY	.common/Release.key /tmp/Release.key
RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

# Invalidate cache once the repository is updated
ADD	$OSMOCOM_REPO/Release /tmp/Release
