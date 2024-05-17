# Image for building all Osmocom projects in master/gerrit/ttcn3 jenkins jobs
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/${OSMOCOM_REPO_PATH}/nightly/Debian_12/"
ARG	UID
ARG	LLVM_VERSION="14.0.0"

# Copy from common dir
COPY	.common/respawn.sh /usr/local/bin/respawn.sh
COPY	.common/Release.key /etc/apt/trusted.gpg.d/obs.osmocom.org.asc

# Configure build user, disable installing man pages
# * /usr/local: osmo-python-tests's contrib/jenkins.sh writes there
# * man pages: without them we avoid waiting for "generating manpages"
RUN	set -x && \
	useradd --uid=${UID} build && \
	mkdir /build && \
	chown -R build:build /build /usr/local && \
	\
	echo "path-exclude=/usr/share/man/*" \
		> /etc/dpkg/dpkg.cfg.d/exclude-man-pages && \
	rm -rf /usr/share/man/

# Install LLVM-embedded-toolchain-for-Arm
RUN	if [ "$(arch)" != "x86_64" ]; then \
		echo "ERROR: use debian-bookworm-build-arm instead"; \
		exit 1; \
	fi && \
	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		libtinfo5 \
		wget \
		&& \
	apt-get clean && \
	wget https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-${LLVM_VERSION}/LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	tar -xf LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	rm LLVMEmbeddedToolchainForArm-${LLVM_VERSION}-linux.tar.gz && \
	mv LLVMEmbeddedToolchainForArm-${LLVM_VERSION} /opt/llvm-arm && \
	/opt/llvm-arm/bin/clang --version && \
	/opt/llvm-arm/bin/clang --print-targets

# Install packages from Debian repositories (alphabetic order)
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		asciidoc \
		asciidoc-dblatex \
		autoconf \
		autoconf-archive \
		autogen \
		automake \
		bc \
		bison \
		build-essential \
		bzip2 \
		ca-certificates \
		ccache \
		cmake \
		coccinelle \
		cppcheck \
		curl \
		dahdi-source \
		dblatex \
		dbus \
		debhelper \
		devscripts \
		dh-autoreconf \
		docbook5-xml \
		doxygen \
		equivs \
		flex \
		g++ \
		gawk \
		gcc \
		gcc-arm-none-eabi \
		ghostscript \
		git \
		gnupg \
		graphviz \
		htop \
		iproute2 \
		latexmk \
		lcov \
		libaio-dev \
		libasound2-dev \
		libbladerf-dev \
		libboost-all-dev \
		libc-ares-dev \
		libcdk5-dev \
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
		libnftables-dev \
		libnftnl-dev \
		libnl-3-dev \
		libnl-route-3-dev \
		liboping-dev \
		libortp-dev \
		libpcap-dev \
		libpcsclite-dev \
		libreadline-dev \
		librsvg2-bin \
		libsctp-dev \
		libsigsegv-dev \
		libsnmp-dev \
		libsofia-sip-ua-glib-dev \
		libsqlite3-dev \
		libssl-dev \
		libtalloc-dev \
		libtinfo5 \
		libtool \
		liburing-dev \
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
		patchelf \
		picolibc-arm-none-eabi \
		pkg-config \
		pylint \
		python3 \
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
		swig \
		systemd \
		tcpdump \
		telnet \
		tex-gyre \
		texinfo \
		unzip \
		virtualenv \
		xsltproc \
		&& \
	apt-get clean

# Install pip dependencies (alphabetic order)
# break-system-packages: inside docker it's fine to install pkgs system-wide
ADD	https://gitea.osmocom.org/sim-card/pysim/raw/branch/master/requirements.txt /tmp/pysim_requirements.txt
RUN	set -x && \
	cat /tmp/pysim_requirements.txt && \
	pip3 install --break-system-packages \
		'git+https://github.com/eriwen/lcov-to-cobertura-xml.git' \
		'git+https://github.com/osmocom/sphinx-argparse@master#egg=sphinx-argparse' \
		'git+https://github.com/podshumok/python-smpplib.git' \
		'pydbus' \
		'pysispm' \
		'sphinx' \
		'sphinxcontrib-napoleon' \
		-r /tmp/pysim_requirements.txt

# Install osmo-python-tests
ADD	https://gerrit.osmocom.org/plugins/gitiles/python/osmo-python-tests/+/master?format=TEXT /tmp/osmo-python-tests-commit
RUN	set -x && \
	git clone --depth=1 https://gerrit.osmocom.org/python/osmo-python-tests osmo-python-tests && \
	cd osmo-python-tests && \
	python3 setup.py clean build install && \
	cd .. && \
	rm -rf osmo-python-tests

# Install osmo-ci.git/scripts to /usr/local/bin
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ci/+/master?format=TEXT /tmp/osmo-ci-commit
RUN 	set -x && \
	git clone --depth=1 https://gerrit.osmocom.org/osmo-ci osmo-ci && \
	su build -c "cd osmo-ci/scripts && cp -v *.sh *.py /usr/local/bin" && \
	rm -rf osmo-ci

# Install osmo-gsm-manuals to /opt/osmo-gsm-manuals
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-gsm-manuals/+/master?format=TEXT /tmp/osmo-gsm-manuals-commit
RUN	git -C /opt clone --depth=1 https://gerrit.osmocom.org/osmo-gsm-manuals

# Install packages from Osmocom OBS nightly repository
# * osmo-remsim: libulfius
# * osmo-trx: liblimesuite-dev, libuhd-dev
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	set -x && \
	echo "deb [signed-by=/etc/apt/trusted.gpg.d/obs.osmocom.org.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-nightly.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		liblimesuite-dev \
		libuhd-dev \
		libulfius-dev \
		&& \
	apt-get clean
