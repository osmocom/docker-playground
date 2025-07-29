ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	DISTRO

ARG	OPEN5GS_REPO_HOST="https://download.opensuse.org"
ARG	OPEN5GS_REPO_PATH="repositories/home:/acetcom:/open5gs:"
ARG	OPEN5GS_REPO="${OPEN5GS_REPO_HOST}/${OPEN5GS_REPO_PATH}/latest/Debian_12"
ARG	OPEN5GS_KEY=/usr/share/keyrings/open5gs-latest.asc
ARG	MONGODB_KEY=/usr/share/keyrings/mongodb-org.asc


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg \
		iproute2 \
		iputils-ping \
		libcap2-bin \
		net-tools \
		sudo \
		wget

RUN	wget "https://pgp.mongodb.com/server-5.0.asc" -O "$MONGODB_KEY"
RUN	case "$DISTRO" in \
	debian-*) \
		DEBIAN_VERSION=$(echo "$DISTRO" | cut -d "-" -f2); \
	if [ "x${DEBIAN_VERSION}" = "xbookworm" ]; then \
		echo "Using bullseye since bookworm mongodb-org package is not available. Furthermore, manually install required libssl1.1." && \
		DEBIAN_VERSION="bullseye" && \
		wget "http://archive.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb10u6_amd64.deb" && \
		dpkg -i "libssl1.1_1.1.1n-0+deb10u6_amd64.deb" && \
		rm "libssl1.1_1.1.1n-0+deb10u6_amd64.deb"; \
	fi; \
	echo "deb [signed-by=$MONGODB_KEY] http://repo.mongodb.org/apt/debian ${DEBIAN_VERSION}/mongodb-org/5.0 main" \
		> /etc/apt/sources.list.d/mongodb-org.list \
		;; \
	centos*) \
	echo "TODO: centos" && \
		exit 1 \
		;; \
	esac

RUN	echo "deb [signed-by=$OPEN5GS_KEY] $OPEN5GS_REPO/ ./" \
		> /etc/apt/sources.list.d/open5gs.list
RUN	wget "$OPEN5GS_REPO/Release.key" -O "$OPEN5GS_KEY"

RUN	apt-get update && \
	apt-get install -y \
		mongodb-org \
		open5gs

# create a user
ARG	username=osmocom
RUN	useradd -m ${username} && \
	echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
	chmod 0440 /etc/sudoers.d/${username}
