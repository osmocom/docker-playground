# Image used to run contrib/jenkins.sh scripts of a few Osmocom projects on
# arm. Keep this image minimal so the rpis don't need forever to build it.
# See master-builds.yml, gerrit-verifications.yml in osmo-ci.git.
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/arm32v7/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/Debian_12/"
ARG	UID

# Copy from common dir
COPY	.common/Release.key /etc/apt/trusted.gpg.d/obs.osmocom.org.asc

# Configure build user, disable installing man pages
# * man pages: without them we avoid waiting for "generating manpages"
RUN	set -x && \
	useradd --uid=${UID} -d /build -m build && \
	chown -R build:build /usr/local && \
	\
	echo "path-exclude=/usr/share/man/*" \
		> /etc/dpkg/dpkg.cfg.d/exclude-man-pages && \
	rm -rf /usr/share/man/

# Install packages from Debian repositories (alphabetic order)
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		ca-certificates \
		ccache \
		g++ \
		gcc \
		git \
		libbladerf-dev \
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

# Install packages from Osmocom OBS nightly repository
# * osmo-trx: liblimesuite-dev, libuhd-dev
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	set -x && \
	echo "deb [signed-by=/etc/apt/trusted.gpg.d/obs.osmocom.org.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-nightly.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		liblimesuite-dev \
		libuhd-dev \
		&& \
	apt-get clean
