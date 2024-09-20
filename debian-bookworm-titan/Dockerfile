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
		ccache \
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

# Ccache is installed above so it can be optionally used when rebuilding the
# testsuites inside the docker containers. Don't use it by default.
ENV	USE_CCACHE=0

# Binary-only transcoding library for RANAP/RUA/HNBAP to work around TITAN only implementing BER
RUN	set -x && \
	export DPKG_ARCH="$(dpkg --print-architecture)" && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode0_0.5_${DPKG_ARCH}.deb && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode-dev_0.5_${DPKG_ARCH}.deb && \
	dpkg -i ./libfftranscode0_0.5_${DPKG_ARCH}.deb ./libfftranscode-dev_0.5_${DPKG_ARCH}.deb && \
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

# Add eclipse-titan from osmocom:latest, invalidate cache when :latest changes
RUN	echo "deb [signed-by=/usr/share/keyrings/osmocom-latest.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		eclipse-titan \
		&& \
	apt-get clean

# Clone osmo-ttcn3-hacks and deps, invalidate cache if deps change (OS#5017)
# chown: gerrit-verifications will potentially update the deps as UID=1000
RUN	git clone https://gerrit.osmocom.org/osmo-ttcn3-hacks && \
	make -j8 -C /osmo-ttcn3-hacks deps
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/refs/heads/master/deps/Makefile?format=TEXT /tmp/deps-Makefile
RUN	if ! diff -q /tmp/deps-Makefile /osmo-ttcn3-hacks/deps/Makefile; then \
		cd /osmo-ttcn3-hacks && \
		git pull && \
		make -j8 deps; \
	fi && \
	chown -R 1000:1000 /osmo-ttcn3-hacks/deps
