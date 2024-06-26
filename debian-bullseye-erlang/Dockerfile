ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:bullseye
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/latest/Debian_11/"

# install the erlang vm and rebar (2)
RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		erlang \
		rebar

# add rebar3
ARG	REBAR3_VERSION="3.18.0"
ADD https://github.com/erlang/rebar3/archive/refs/tags/${REBAR3_VERSION}.tar.gz /tmp/rebar3.tar.gz
RUN tar -zxf /tmp/rebar3.tar.gz && \
		cd rebar3-${REBAR3_VERSION} && \
		./bootstrap && \
		install -Dm0755 "rebar3" "/usr/bin/rebar3"

# install ninimal build utilities as well as system utilities
RUN	apt-get update && \
	apt-get -y install \
		build-essential \
		git \
		iproute2 \
		netcat-openbsd \
		procps \
		tcpdump \
		vim \
		wget \
		&& \
	apt-get clean

# install additional C-language / system dependencies of our Erlang projects
RUN	apt-get update && \
	apt-get -y install \
		libpcap-dev \
		libsctp1 \
		&& \
	apt-get clean

# add osmocom latest repo, should we ever require packages from there
RUN	apt-get update && apt-get install -y \
		ca-certificates \
		gnupg
COPY	.common/Release.key /usr/share/keyrings/osmocom-latest.asc
RUN	echo "deb [signed-by=/usr/share/keyrings/osmocom-latest.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list
ADD	$OSMOCOM_REPO/Release /tmp/Release

# add a non-root user under which we will normaly execute build tests
RUN	useradd -m build
WORKDIR	/home/build
USER	build
