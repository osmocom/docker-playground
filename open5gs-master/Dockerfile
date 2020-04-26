FROM debian:buster

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        ninja-build \
        build-essential \
        flex \
        bison \
        git \
        libsctp-dev \
        libgnutls28-dev \
        libgcrypt-dev \
        libssl-dev \
        libidn11-dev \
        libmongoc-dev \
        libbson-dev \
        libyaml-dev \
        iproute2 \
        ca-certificates \
        netbase \
        pkg-config && \
    apt-get clean
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install meson


RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        git-buildpackage \
        debhelper \
        devscripts \
        vim \
        sudo \
        iputils-ping \
        net-tools && \
    apt-get clean

COPY setup.sh /root

# crate user
ARG username=osmocom
RUN useradd -m --uid=1000 ${username} && \
    echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username}

WORKDIR /home/${username}


# build + install open5gs

ARG GITHUB_USER=open5gs
ARG GITHUB_REPO=open5gs
ARG OPEN5GS_BRANCH=master
RUN git clone https://github.com/$GITHUB_USER/$GITHUB_REPO
ADD https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/git/refs/heads/$OPEN5GS_BRANCH /root/open5gs-ver.json

RUN cd $GITHUB_REPO && \
 git fetch && git checkout -f -B $OPEN5GS_BRANCH origin/$OPEN5GS_BRANCH && \
    meson build && ninja -C build install
