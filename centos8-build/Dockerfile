ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=almalinux:8
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Make additional development libraries available from PowerTools and Osmocom nightly (e.g. libdbi)
RUN	dnf install -y dnf-utils wget && \
	yum config-manager --set-enabled powertools && \
	export MIRROR_HTTPS="$(echo $OSMOCOM_REPO_MIRROR | sed s/^http:/https:/)" && \
	{ echo "[network_osmocom_nightly]"; \
	  echo "name=Nightly packages of the Osmocom project (CentOS_8)"; \
	  echo "type=rpm-md"; \
	  echo "baseurl=${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/CentOS_8/"; \
	  echo "gpgcheck=1"; \
	  echo "gpgkey=${MIRROR_HTTPS}/${OSMOCOM_REPO_PATH}/nightly/CentOS_8/repodata/repomd.xml.key"; \
	  echo "enabled=1"; \
	} > /etc/yum.repos.d/network:osmocom:nightly.repo

RUN	dnf install -y \
		autoconf \
		autoconf-archive \
		autogen \
		automake \
		bison \
		c-ares-devel \
		cppcheck \
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
		libsofia-sip-ua-glib3 \
		libtalloc-devel \
		libtool \
		libusb1-devel \
		lksctp-tools-devel \
		make \
		ncurses-devel \
		openssl-devel \
		ortp-devel \
		pcsc-lite-devel \
		pkg-config \
		readline-devel \
		sqlite \
		sqlite-devel \
		telnet

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

# Invalidate cache once the repository is updated
ADD	${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
