ARG	REGISTRY=docker.io
ARG	USER
FROM	$USER/debian-bullseye-build


RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        cmake \
        vim \
        sudo \
        iproute2 \
        iputils-ping \
        libcap2-bin \
        net-tools && \
    apt-get clean

# crate user
ARG username=osmocom
RUN useradd -m --uid=1000 ${username} && \
    echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
    chmod 0440 /etc/sudoers.d/${username}

WORKDIR /home/${username}


# clone open5gs
ARG GITHUB_USER=open5gs
ARG GITHUB_REPO=open5gs
ARG OPEN5GS_BRANCH=main
RUN git clone https://github.com/$GITHUB_USER/$GITHUB_REPO

# install dependencies specified in debian/control (cache them)
RUN cd $GITHUB_REPO && \
    git checkout $OPEN5GS_BRANCH && \
    apt-get build-dep -y .

ADD https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/git/refs/heads/$OPEN5GS_BRANCH /root/open5gs-ver.json

# update the source code (if needed)
RUN cd $GITHUB_REPO && \
    git fetch && git checkout -f -B $OPEN5GS_BRANCH origin/$OPEN5GS_BRANCH

# update installed dependencies, install missing (if any)
RUN cd $GITHUB_REPO && \
    apt-get build-dep -y .

# build + install open5gs
RUN cd $GITHUB_REPO && \
    meson build \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --libdir=lib/x86_64-linux-gnu \
        --libexecdir=lib/x86_64-linux-gnu && \
    meson configure -Dmetrics_impl=prometheus build && \
    ninja -C build install
