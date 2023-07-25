ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bullseye
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_TESTSUITE_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO="$OSMOCOM_REPO_TESTSUITE_MIRROR/packages/osmocom:/latest/Debian_11/"

RUN	apt-get update && apt-get install -y \
		ca-certificates \
		gnupg

COPY	.common/Release.key /usr/share/keyrings/osmocom-latest.asc
RUN	echo "deb [signed-by=/usr/share/keyrings/osmocom-latest.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list

RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends --no-install-suggests \
		build-essential \
		git \
		iputils-ping \
		netcat-openbsd \
		procps \
		python3-pip \
		python3-setuptools \
		tcpdump \
		vim \
		wireshark-common \
		&& \
	apt-get clean

#Install titan.core dependencies listed in debian/control:
RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends --no-install-suggests \
		bison \
		debhelper \
		default-jdk \
		expect \
		flex \
		libedit-dev \
		libncurses5-dev \
		libssl-dev \
		libxml2-dev \
		expect \
		libedit-dev \
		libpcap-dev \
		libpcre3-dev \
		libsctp-dev \
		libssl-dev \
		libxml2-dev \
		make \
		perl \
		python3 \
		gcc \
		&& \
	apt-get clean

# Remember to adapt the URL fetching /root/titan.core-ver.json if TITAN_REPO_URL is changed!
ARG TITAN_REPO_URL=https://gitlab.eclipse.org/eclipse/titan/titan.core.git
ARG TITAN_BRANCH=master
ARG TITAN_REPO_DIR=titan.core
# clone titan.core.git
RUN git clone $TITAN_REPO_URL

ADD https://gitlab.eclipse.org/api/v4/projects/eclipse%2Ftitan%2Ftitan.core/repository/commits/$TITAN_BRANCH /root/titan.core-ver.json

# update the source code (if needed)
RUN cd $TITAN_REPO_DIR && \
    git fetch && git checkout -f -B $TITAN_BRANCH origin/$TITAN_BRANCH

# build + install titan.core onto /titan.core/Install
RUN cd $TITAN_REPO_DIR && \
    make -j$(nproc) prefix=/usr install

# Install files in proper places:
RUN cd /$TITAN_REPO_DIR/Install && \
	cp -r bin/* /usr/bin/ && \
	mkdir -p /usr/share/titan/etc/ && cp -r etc/* /usr/share/titan/etc/ && \
	mkdir -p /usr/share/titan/help/ && cp -r help/* /usr/share/titan/help/ && \
	mkdir -p /usr/include/titan/ && cp -r include/* /usr/include/titan/ && \
	mkdir -p /usr/lib/titan/ && cp -r lib/* /usr/lib/titan/

# This is required for obtaining talloc reports from the SUT
RUN	pip3 install git+https://gitea.osmocom.org/cellular-infrastructure/osmo-python-tests

# binary-only transcoding library for RANAP/RUA/HNBAP to work around TITAN only implementing BER
RUN	apt-get update && \
	apt-get -y install wget
RUN	DPKG_ARCH="$(dpkg --print-architecture)" && export $DPKG_ARCH && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode0_0.5_${DPKG_ARCH}.deb && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode-dev_0.5_${DPKG_ARCH}.deb && \
	dpkg -i ./libfftranscode0_0.5_${DPKG_ARCH}.deb ./libfftranscode-dev_0.5_${DPKG_ARCH}.deb && \
	apt install --fix-broken && \
	rm libfftranscode*.deb

RUN	git config --global user.email docker@dock.er && \
	git config --global user.name "Dock Er"

# clone osmo-ttcn3-hacks and deps, invalidate cache if deps change (OS#5017)
RUN	git clone https://gerrit.osmocom.org/osmo-ttcn3-hacks && \
	make -j$(nproc) -C /osmo-ttcn3-hacks deps
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ttcn3-hacks/+/refs/heads/master/deps/Makefile?format=TEXT /tmp/deps-Makefile
RUN	if ! diff -q /tmp/deps-Makefile /osmo-ttcn3-hacks/deps/Makefile; then \
		cd /osmo-ttcn3-hacks && \
		git pull && \
		make -j$(nproc) deps; \
	fi

ADD	.common/ttcn3-docker-prepare.sh /usr/local/bin/ttcn3-docker-prepare
ADD	.common/ttcn3-docker-run.sh /usr/local/bin/ttcn3-docker-run
ADD	.common/pipework /usr/local/bin/pipework
