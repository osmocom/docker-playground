# osmo-gsm-tester is still using this (OS#6126).
# See master-builds.yml, gerrit-verifications.yml in osmo-ci.git.

ARG	DEBIAN_VERSION=buster
ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:${DEBIAN_VERSION}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"

# Make "$DEBIAN_VERSION" available after FROM
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DEBIAN_VERSION

# LLVM-embedded-toolchain-for-Arm version
ARG	LLVM_VERSION="14.0.0"

# Install apt dependencies (keep in alphabetic order)
RUN \
	[ "$(arch)" = "x86_64" ] && dpkg --add-architecture i386; \
	DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		asciidoc \
		asciidoc-dblatex \
		autoconf \
		autoconf-archive \
		automake \
		bc \
		bison \
		bzip2 \
		ca-certificates \
		ccache \
		cmake \
		coccinelle \
		cppcheck \
		dahdi-source \
		dblatex \
		dbus \
		debhelper \
		devscripts \
		dh-autoreconf \
		dh-systemd \
		docbook5-xml \
		doxygen \
		flex \
		g++ \
		gawk \
		gcc \
		gcc-arm-none-eabi \
		ghostscript \
		git \
		git-buildpackage \
		graphviz \
		htop \
		inkscape \
		latexmk \
		lcov \
		libaio-dev \
		libasound2-dev \
		libboost-all-dev \
		libc-ares-dev \
		libcsv-dev \
		libdbd-sqlite3 \
		libdbi-dev \
		libelf-dev \
		libffi-dev \
		libfftw3-dev \
		libgmp-dev \
		libgnutls28-dev \
		libgps-dev \
		libgsm1-dev \
		libjansson-dev \
		liblua5.3-dev \
		libmnl-dev \
		libncurses5-dev \
		libnewlib-arm-none-eabi \
		libnl-3-dev \
		libnl-route-3-dev \
		liboping-dev \
		libortp-dev \
		libpcap-dev \
		libpcsclite-dev \
		libreadline-dev \
		libsctp-dev \
		libsigsegv-dev \
		libsnmp-dev \
		libsofia-sip-ua-glib-dev \
		libsqlite3-dev \
		libssl-dev \
		libtalloc-dev \
		libtinfo5 \
		libtool \
		libusb-1.0-0-dev \
		libusb-dev \
		libxml2-utils \
		libzmq3-dev \
		locales \
		lua-socket \
		make \
		mscgen \
		ofono \
		openssh-client \
		osc \
		patchelf \
		pkg-config \
		pylint \
		python-pip \
		python-setuptools \
		python-yaml \
		python2.7 \
		python3 \
		python3-cryptography \
		python3-gi \
		python3-mako \
		python3-nwdiag \
		python3-pip \
		python3-pyflakes \
		python3-setuptools \
		python3-usb \
		python3-yaml \
		rsync \
		sdcc \
		source-highlight \
		sqlite3 \
		stow \
		sudo \
		systemd \
		tcpdump \
		tex-gyre \
		texinfo \
		unzip \
		wget \
		xsltproc

RUN	set -x && \
	[ "$(arch)" = "x86_64" ] || exit 0; \
	wget -q https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-${LLVM_VERSION}/LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	tar -xf LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	rm LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	mv LLVMEmbeddedToolchainForArm-${LLVM_VERSION} /opt/llvm-arm && \
	/opt/llvm-arm/bin/clang --version && \
	/opt/llvm-arm/bin/clang --print-targets

# Install pip dependencies (keep in alphabetic order)
RUN pip3 install \
	'git+https://github.com/eriwen/lcov-to-cobertura-xml.git' \
	'git+https://github.com/osmocom/sphinx-argparse@master#egg=sphinx-argparse' \
	'git+https://github.com/podshumok/python-smpplib.git' \
	'pydbus' \
	'pysispm' \
	'sphinx' \
	'sphinxcontrib-napoleon' \
	'swig'

# match the outside user
RUN useradd --uid=1000 build
#RUN echo "build ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/build

RUN mkdir /build
RUN chown build:build /build

# Install osmo-python-tests for python2 (when building old tags again new releases)
ARG OSMO_PYTHON2_TESTS_COMMIT=fb4b813d4df62b7b2445bdced961eb1847267eed
RUN git clone https://gerrit.osmocom.org/python/osmo-python-tests osmo-python-tests2 && \
	cd osmo-python-tests2 && \
	git checkout $OSMO_PYTHON2_TESTS_COMMIT && \
	python2 setup.py clean build install

# Install osmo-python-tests for python3
ADD https://gerrit.osmocom.org/plugins/gitiles/python/osmo-python-tests/+/master?format=TEXT /tmp/osmo-python-tests-commit
RUN git clone https://gerrit.osmocom.org/python/osmo-python-tests osmo-python-tests3 && \
	cd osmo-python-tests3 && \
	python3 setup.py clean build install

# Install osmo-ci.git/scripts to /usr/local/bin
ADD https://gerrit.osmocom.org/plugins/gitiles/osmo-ci/+/master?format=TEXT /tmp/osmo-ci-commit
RUN git clone https://gerrit.osmocom.org/osmo-ci osmo-ci && \
	cp -v $(find osmo-ci/scripts \
		-maxdepth 1 \
		-type f ) \
	   /usr/local/bin

# Install osmo-gsm-manuals to /opt/osmo-gsm-manuals
ADD https://gerrit.osmocom.org/plugins/gitiles/osmo-gsm-manuals/+/master?format=TEXT /tmp/osmo-gsm-manuals-commit
RUN git -C /opt clone https://gerrit.osmocom.org/osmo-gsm-manuals

# Set a UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Install packages from Osmocom OBS repositories:
# * osmo-remsim: libulfius
# * osmo-trx: liblimesuite-dev, libuhd-dev
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/Debian_10/"
COPY	.common/Release.key /tmp/Release.key
RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		liblimesuite-dev \
		libuhd-dev \
		libulfius-dev && \
	apt-get clean

# osmo-python-tests' contrib/jenkins.sh writes to /usr/local as user
RUN chown -R build:build /usr/local
