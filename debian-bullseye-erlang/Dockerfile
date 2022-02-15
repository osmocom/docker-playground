ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:bullseye
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
ARG	OSMOCOM_REPO_PATH="repositories/network:/osmocom:"

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/latest/Debian_11/"

# install the erlang vm and rebar (2)
RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		erlang \
		rebar

# add rebar3
ADD	https://s3.amazonaws.com/rebar3/rebar3 /usr/bin/rebar3
RUN	chmod 0755 /usr/bin/rebar3

# install ninimal build utilities as well as system utilities
RUN	apt-get update && \
	apt-get -y install \
		build-essential \
		git \
		procps \
		tcpdump \
		vim \
		netcat-openbsd \
		wget \
		&& \
	apt-get clean

# install additional C-language / system dependencies of our Erlang projects
RUN	apt-get update && \
	apt-get -y install \
		libpcap-dev \
		&& \
	apt-get clean

# add osmocom latest repo, should we ever require packages from there
RUN	apt-get update && apt-get install -y \
		gnupg
COPY	.common/Release.key /tmp/Release.key
RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list
ADD	$OSMOCOM_REPO/Release /tmp/Release

# add a non-root user under which we will normaly execute build tests
RUN	useradd -m build
WORKDIR	/home/build
USER	build
