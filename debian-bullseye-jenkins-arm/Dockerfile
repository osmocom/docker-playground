# Image used to run contrib/jenkins.sh scripts of a few Osmocom projects on
# arm. Keep this image minimal so the rpis don't need forever to build it.
# See master-builds.yml, gerrit-verifications.yml in osmo-ci.git.

ARG	DEBIAN_VERSION=bullseye-slim
ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:${DEBIAN_VERSION}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"

# Install apt dependencies (keep in alphabetic order)
RUN \
	DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		ca-certificates \
		ccache \
		g++ \
		gcc \
		git \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-thread-dev \
		libfftw3-dev \
		libgnutls28-dev \
		libmnl-dev \
		libortp-dev \
		libpcsclite-dev \
		libsctp-dev \
		libtalloc-dev \
		libtool \
		liburing-dev \
		libusb-1.0-0-dev \
		make \
		pkg-config \
		python3-minimal \
		python3-setuptools \
		sdcc \
		stow \
		&& \
	apt-get clean

# match the outside user
RUN useradd --uid=1000 build

RUN mkdir /build
RUN chown build:build /build

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

# Install packages from Osmocom OBS repositories:
# * osmo-trx: liblimesuite-dev, libuhd-dev
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/Debian_10/"
COPY	.common/Release.key /etc/apt/trusted.gpg.d/obs.osmocom.org.asc
RUN	echo "deb [signed-by=/etc/apt/trusted.gpg.d/obs.osmocom.org.asc] " \
		$OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		liblimesuite-dev \
		libuhd-dev \
		&& \
	apt-get clean
