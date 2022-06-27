ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bullseye
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_TESTSUITE_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO="$OSMOCOM_REPO_TESTSUITE_MIRROR/packages/osmocom:/latest/Debian_11/"

RUN	apt-get update && apt-get install -y \
		ca-certificates \
		gnupg

COPY	.common/Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
		eclipse-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends --no-install-suggests \
		build-essential \
		git \
		inetutils-ping \
		netcat-openbsd \
		procps \
		python3-pip \
		python3-setuptools \
		tcpdump \
		vim \
		wireshark-common \
		&& \
	apt-get clean

# This is required for obtaining talloc reports from the SUT
RUN	pip3 install git+git://git.osmocom.org/python/osmo-python-tests

# somehow Debian folks updated the gcc version but not titan :/
RUN	sed -i 's/^#error/\/\/#error/' /usr/include/titan/cversion.h


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
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git && \
	make -j8 -C /osmo-ttcn3-hacks deps
ADD	https://git.osmocom.org/osmo-ttcn3-hacks/plain/deps/Makefile /tmp/deps-Makefile
RUN	if ! diff -q /tmp/deps-Makefile /osmo-ttcn3-hacks/deps/Makefile; then \
		cd /osmo-ttcn3-hacks && \
		git pull && \
		make -j8 deps; \
	fi

ADD	ttcn3-docker-prepare.sh /usr/local/bin/ttcn3-docker-prepare
ADD	ttcn3-docker-run.sh /usr/local/bin/ttcn3-docker-run
ADD	.common/pipework /usr/local/bin/pipework
