ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_TESTSUITE_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO="$OSMOCOM_REPO_TESTSUITE_MIRROR/packages/osmocom:/latest/Debian_12/"

# Copy from common dir
COPY	.common/Release.key /usr/share/keyrings/osmocom-latest.asc
COPY	.common/pipework /usr/local/bin/pipework
COPY	.common/ttcn3-docker-prepare.sh /usr/local/bin/ttcn3-docker-prepare
COPY	.common/ttcn3-docker-run.sh /usr/local/bin/ttcn3-docker-run

# Install packages from Debian repositories (alphabetic order)
ENV	DEBIAN_FRONTEND=noninteractive
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		git \
		iproute2 \
		iputils-ping \
		netcat-openbsd \
		procps \
		python3-setuptools \
		tcpdump \
		vim \
		wget \
		wireshark-common \
		&& \
	apt-get clean

# Binary-only transcoding library for RANAP/RUA/HNBAP to work around TITAN only implementing BER
RUN	set -x && \
	export DPKG_ARCH="$(dpkg --print-architecture)" && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode0_0.6_${DPKG_ARCH}.deb && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode-dev_0.6_${DPKG_ARCH}.deb && \
	dpkg -i ./libfftranscode0_0.6_${DPKG_ARCH}.deb ./libfftranscode-dev_0.6_${DPKG_ARCH}.deb && \
	apt install --fix-broken && \
	rm libfftranscode*.deb

# Install osmo-python-tests (for obtaining talloc reports from SUT)
ADD	https://gerrit.osmocom.org/plugins/gitiles/python/osmo-python-tests/+/master?format=TEXT /tmp/osmo-python-tests-commit
RUN	set -x && \
	git clone --depth=1 https://gerrit.osmocom.org/python/osmo-python-tests osmo-python-tests && \
	cd osmo-python-tests && \
	python3 setup.py clean build install && \
	cd .. && \
	rm -rf osmo-python-tests

# Configure git
RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

#
# Start of build + install titan from git
# (The rest is the same as debian-bookworm-titan)
#

# Remember to adapt the URL fetching /root/titan.core-ver.json if TITAN_REPO_URL is changed!
ARG	TITAN_REPO_URL=https://gitlab.eclipse.org/eclipse/titan/titan.core.git
ARG	TITAN_BRANCH=master
ARG	TITAN_REPO_DIR=titan.core

# Install titan.core dependencies listed in debian/control
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		bison \
		debhelper \
		default-jdk \
		expect \
		flex \
		gcc \
		libedit-dev \
		libncurses5-dev \
		libpcap-dev \
		libpcre3-dev \
		libsctp-dev \
		libssl-dev \
		libxml2-dev \
		make \
		perl \
		python3 \
		&& \
	apt-get clean

# Clone and update the source code (if needed)
RUN	git clone $TITAN_REPO_URL
ADD	https://gitlab.eclipse.org/api/v4/projects/eclipse%2Ftitan%2Ftitan.core/repository/commits/$TITAN_BRANCH /root/titan.core-ver.json
RUN	set -x && \
	cd $TITAN_REPO_DIR && \
	git fetch && git checkout -f -B $TITAN_BRANCH origin/$TITAN_BRANCH

# Build + install titan.core onto /titan.core/Install
RUN	set -x && \
	cd $TITAN_REPO_DIR && \
	make -j$(nproc) prefix=/usr install

# Install files in proper places:
RUN	set -x && \
	cd /$TITAN_REPO_DIR/Install && \
	cp -r bin/* /usr/bin/ && \
	mkdir -p /usr/share/titan/etc/ && cp -r etc/* /usr/share/titan/etc/ && \
	mkdir -p /usr/share/titan/help/ && cp -r help/* /usr/share/titan/help/ && \
	mkdir -p /usr/include/titan/ && cp -r include/* /usr/include/titan/ && \
	mkdir -p /usr/lib/titan/ && cp -r lib/* /usr/lib/titan/

#
# End of build + install titan from git
#

# Clone osmo-ttcn3-hacks and deps, invalidate cache if deps change (OS#5017)
RUN	git clone https://gerrit.osmocom.org/osmo-ttcn3-hacks && \
	make -j8 -C /osmo-ttcn3-hacks deps
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/refs/heads/master/deps/Makefile?format=TEXT /tmp/deps-Makefile
RUN	if ! diff -q /tmp/deps-Makefile /osmo-ttcn3-hacks/deps/Makefile; then \
		cd /osmo-ttcn3-hacks && \
		git pull && \
		make -j8 deps; \
	fi
