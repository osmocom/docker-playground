ARG	REGISTRY=docker.io
ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		cmake \
		vim \
		sudo \
		iproute2 \
		iputils-ping \
		libcap2-bin \
		net-tools \
		wget && \
	apt-get clean

ARG	MONGODB_KEY=/usr/share/keyrings/mongodb-org.asc
RUN	wget "https://pgp.mongodb.com/server-5.0.asc" -O "$MONGODB_KEY"
RUN	case "$DISTRO" in \
	debian-*) \
		DEBIAN_VERSION=$(echo "$DISTRO" | cut -d "-" -f2); \
		if [ "x${DEBIAN_VERSION}" = "xbookworm" ]; then \
			echo "Using bullseye since bookworm mongodb-org package is not available. Furthermore, manually install required libssl1.1." && \
			DEBIAN_VERSION="bullseye" && \
			wget "http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb10u6_amd64.deb" && \
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
RUN	apt-get update && \
	apt-get install -y \
		mongodb-org

# create a user
ARG	username=osmocom
RUN	useradd -m ${username} && \
	echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
	chmod 0440 /etc/sudoers.d/${username}

WORKDIR	/home/${username}


# clone open5gs
ARG	GITHUB_USER=open5gs
ARG	GITHUB_REPO=open5gs
ARG	OPEN5GS_BRANCH=main
RUN	git clone https://github.com/$GITHUB_USER/$GITHUB_REPO

# install dependencies specified in debian/control (cache them)
RUN	cd $GITHUB_REPO && \
	git checkout $OPEN5GS_BRANCH && \
	apt-get build-dep -y .

ADD	https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/git/refs/heads/$OPEN5GS_BRANCH /root/open5gs-ver.json

# update the source code (if needed)
RUN	cd $GITHUB_REPO && \
	git fetch && git checkout -f -B $OPEN5GS_BRANCH origin/$OPEN5GS_BRANCH

# update installed dependencies, install missing (if any)
RUN	cd $GITHUB_REPO && \
	apt-get build-dep -y .

# build + install open5gs
RUN	cd $GITHUB_REPO && \
	meson build \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--libdir=lib/x86_64-linux-gnu \
		--libexecdir=lib/x86_64-linux-gnu && \
	meson configure build && \
	ninja -C build install && \
	install -m 0755 build/misc/db/open5gs-dbctl /usr/bin/open5gs-dbctl
