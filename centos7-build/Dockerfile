ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=centos:centos7
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"

# Use dnf package manager instead of yum, so we can use all the dnf codepaths
# that were originally written for CentOS8 in this CentOS7 image too
RUN	yum install -y dnf

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Set up Osmocom OBS repository
RUN	export MIRROR_HTTPS="$(echo $OSMOCOM_REPO_MIRROR | sed s/^http:/https:/)" && \
	{ echo "[network_osmocom_nightly]"; \
	  echo "name=Nightly packages of the Osmocom project (CentOS_7)"; \
	  echo "type=rpm-md"; \
	  echo "baseurl=${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/CentOS_7/"; \
	  echo "gpgcheck=1"; \
	  echo "gpgkey=${MIRROR_HTTPS}/${OSMOCOM_REPO_PATH}/nightly/CentOS_7/repodata/repomd.xml.key"; \
	  echo "enabled=1"; \
	} > /etc/yum.repos.d/network:osmocom:nightly.repo

RUN	dnf install -y \
		autoconf \
		autoconf-archive \
		autogen \
		automake \
		bison \
		c-ares-devel \
		doxygen \
		fftw-devel \
		flex \
		gawk \
		gcc \
		gcc-c++ \
		git \
		gnupg \
		gnutls-devel \
		gsm-devel \
		libdbi-dbd-sqlite \
		libdbi-devel \
		libpcap-devel \
		libtalloc-devel \
		libtool \
		libusb1-devel \
		lksctp-tools-devel \
		make \
		ncurses-devel \
		openssl-devel \
		ortp-devel \
		pcsc-lite-devel \
		pkgconfig \
		readline-devel \
		sqlite \
		sqlite-devel \
		telnet

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

# Invalidate cache once the repository is updated
ADD	${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/CentOS_7/repodata/repomd.xml /tmp/repomd.xml
