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
		vim \
		sudo \
		iproute2 \
		iputils-ping \
		libcap2-bin \
		net-tools \
		libedit-dev \
		libnewt-dev \
		libssl-dev \
		libncurses5-dev \
		subversion \
		libsqlite3-dev \
		build-essential \
		libjansson-dev \
		libxml2-dev \
		uuid-dev \
		wget && \
	apt-get clean

# create a user
ARG	username=asterisk
RUN	useradd -m ${username} && \
	echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} && \
	chmod 0440 /etc/sudoers.d/${username}

WORKDIR	/home/${username}

# clone pjproject
ARG	PJPROJECT_REMOTE=https://gitea.sysmocom.de/sysmocom/pjproject.git
ARG	PJPROJECT_BRANCH=sysmocom/2.14

RUN	git clone $PJPROJECT_REMOTE
ADD	https://gitea.sysmocom.de/api/v1/repos/sysmocom/pjproject/git/refs/heads/$PJPROJECT_BRANCH /tmp/pjproject-ver

RUN	cd pjproject && \
	git fetch && git checkout $PJPROJECT_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$PJPROJECT_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD

# clone asterisk
ARG	ASTERISK_REMOTE=https://gitea.sysmocom.de/sysmocom/asterisk.git
RUN	git clone $ASTERISK_REMOTE

RUN	cd asterisk && \
	git fetch && git checkout -f -B sysmocom/master origin/sysmocom/master

# Use pjproject from git repo above instead of downloading tar.gz:
RUN	cd asterisk/third-party/pjproject && \
	ln -s ../../../pjproject/ source

RUN	cd asterisk && \
	./bootstrap.sh && \
	./configure && \
	make "-j$(nproc)"

ARG	ASTERISK_BRANCH=sysmocom/master

ADD	https://gitea.sysmocom.de/api/v1/repos/sysmocom/asterisk/git/refs/heads/$ASTERISK_BRANCH /tmp/asterisk-ver

# update the source code (if needed)
RUN	cd asterisk && \
	git fetch && git checkout -B $ASTERISK_BRANCH origin/$ASTERISK_BRANCH

RUN	cd asterisk && \
	make "-j$(nproc)" && \
	make install && \
	make samples && \
	ldconfig

# Required to set up ipsec:
RUN	setcap 'cap_net_admin,cap_sys_resource=ep' /usr/sbin/asterisk
