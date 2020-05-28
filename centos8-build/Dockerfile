FROM	centos:centos8

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Make additional development libraries available from PowerTools and Osmocom nightly (e.g. libdbi)
RUN	dnf install -y dnf-utils wget && \
	yum config-manager --set-enabled PowerTools && \
	cd /etc/yum.repos.d/ && \
	wget https://download.opensuse.org/repositories/network:osmocom:nightly/CentOS_8_Stream/network:osmocom:nightly.repo

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
		sqlite-devel
