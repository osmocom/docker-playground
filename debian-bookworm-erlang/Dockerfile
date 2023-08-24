ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/latest/Debian_12/"
ARG	UID

# Install the erlang vm and rebar (2)
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		erlang \
		rebar \
		&& \
	apt-get clean

# Add rebar3
ARG	REBAR3_VERSION="3.18.0"
ADD	https://github.com/erlang/rebar3/archive/refs/tags/${REBAR3_VERSION}.tar.gz /tmp/rebar3.tar.gz
RUN	set -x && \
	tar -zxf /tmp/rebar3.tar.gz && \
	cd rebar3-${REBAR3_VERSION} && \
	./bootstrap && \
	install -Dm0755 "rebar3" "/usr/bin/rebar3" && \
	rm /tmp/rebar3.tar.gz

# Install minimal build utilities as well as system utilities
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		build-essential \
		git \
		procps \
		tcpdump \
		vim \
		netcat-openbsd \
		wget \
		&& \
	apt-get clean

# Install additional C-language / system dependencies of our Erlang projects
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		libpcap-dev \
		libsctp1 \
		&& \
	apt-get clean

# Add osmocom latest repo, should we ever require packages from there
COPY	.common/Release.key /usr/share/keyrings/osmocom-latest.asc
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg \
		&& \
	apt-get clean && \
	echo "deb [signed-by=/usr/share/keyrings/osmocom-latest.asc] $OSMOCOM_REPO ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list

# Add a non-root user under which we will normaly execute build tests
RUN	useradd --uid=${UID} -m build
WORKDIR	/home/build
USER	build
