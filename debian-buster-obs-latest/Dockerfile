ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian/eol:buster
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/latest/Debian_10/"
ARG	UID

# Copy from common dir
COPY	.common/respawn.sh /usr/local/bin/respawn.sh
COPY	.common/Release.key /usr/share/keyrings/osmocom-latest.asc

# Configure build user, disable installing man pages
# * /usr/local: osmo-python-tests's contrib/jenkins.sh writes there
# * man pages: without them we avoid waiting for "generating manpages"
RUN	set -x && \
	useradd --uid=${UID} -d /build -m build && \
	chown -R build:build /usr/local && \
	\
	echo "path-exclude=/usr/share/man/*" \
		> /etc/dpkg/dpkg.cfg.d/exclude-man-pages && \
	rm -rf /usr/share/man/

# Configure Osmocom latest repository, add telnet for debugging
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		telnet \
		&& \
	apt-get clean && \
	echo "deb [signed-by=/usr/share/keyrings/osmocom-latest.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list

# Invalidate cache once the repository is updated
ADD	$OSMOCOM_REPO/Release /tmp/Release
