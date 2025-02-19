# Image for building https://gitea.osmocom.org/sim-card/aram-applet
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
ARG	UID
ENV	APT_INSTALL="apt-get install -y --no-install-recommends"
ENV	SOURCES_LIST="/etc/apt/sources.list.d/debian9-sources.list"

# Add the build user
RUN	useradd --uid=${UID} -m build && \
	mkdir /cache /build && \
	chown build:build /cache /build

# Install openjdk-8 from Debian 9
# (x11-common gets pulled in as dep and must be installed first or it fails)
RUN	set -x && \
	apt-get update && \
	$APT_INSTALL ca-certificates && \
	echo "deb [trusted=yes] https://archive.debian.org/debian stretch main" >>"$SOURCES_LIST" && \
	echo "deb [trusted=yes] https://archive.debian.org/debian-security stretch/updates main" >>"$SOURCES_LIST" && \
	apt-get update && \
	$APT_INSTALL x11-common && \
	$APT_INSTALL -t stretch ca-certificates-java openjdk-8-jdk-headless && \
	apt-get clean

# Install other packages
RUN	set -x && \
	apt-get update && \
	$APT_INSTALL git && \
	apt-get clean

USER	build

# Build aram-applet once to download and cache dependencies
ADD	https://gerrit.osmocom.org/plugins/gitiles/aram-applet/+/refs/heads/master/build.gradle?format=TEXT /tmp/build.gradle
RUN	set -x && \
	git -C /cache clone --depth=1 https://gerrit.osmocom.org/aram-applet && \
	cd /cache/aram-applet && \
	git submodule update --init && \
	./gradlew build
