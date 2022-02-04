ARG	REGISTRY=docker.io
ARG	USER
FROM	$USER/debian-bullseye-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        meson \
        ninja-build \
        libsctp-dev \
        libgnutls28-dev \
        libgcrypt-dev \
        libssl-dev \
        libidn11-dev \
        libmongoc-dev \
        libbson-dev \
        libyaml-dev \
        libnghttp2-dev \
        libmicrohttpd-dev \
        libcurl4-gnutls-dev \
        iproute2 \
        ca-certificates \
        netbase && \
    apt-get clean

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        vim \
        sudo \
        iputils-ping \
        net-tools && \
    apt-get clean

# crate user
ARG username=osmocom
RUN useradd -m --uid=1000 ${username} && \
    echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username}

WORKDIR /home/${username}


# build + install open5gs

ARG GITHUB_USER=open5gs
ARG GITHUB_REPO=open5gs
ARG OPEN5GS_BRANCH=main
RUN git clone https://github.com/$GITHUB_USER/$GITHUB_REPO
ADD https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/git/refs/heads/$OPEN5GS_BRANCH /root/open5gs-ver.json

RUN cd $GITHUB_REPO && \
 git fetch && git checkout -f -B $OPEN5GS_BRANCH origin/$OPEN5GS_BRANCH && \
    meson build && ninja -C build install
