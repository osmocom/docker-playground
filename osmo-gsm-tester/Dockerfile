ARG	USER
FROM	$USER/debian-stretch-build

MAINTAINER Pau Espin Pedrol <pespin@sysmocom.de>

# Create jenkins user
RUN     useradd -ms /bin/bash jenkins
# Create osmo-gsm-tester group and add user to it
RUN     groupadd osmo-gsm-tester
RUN     usermod -a -G osmo-gsm-tester jenkins

# install osmo-gsm-tester dependencies
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		dbus \
		tcpdump \
		sqlite3 \
		python3 \
		python3-setuptools \
		python3-yaml \
		python3-mako \
		python3-gi \
		python3-numpy \
		python3-wheel \
		ofono \
		patchelf \
		sudo \
		libcap2-bin \
		python3-pip \
		udhcpc \
		iperf3 \
		locales

# install osmo-gsm-tester pip dependencies
RUN	pip3 install \
		"git+https://github.com/podshumok/python-smpplib.git@master#egg=smpplib" \
		pydbus \
		pyusb \
		pysispm

# Intall sshd:
RUN	apt-get update && apt-get install -y openssh-server
RUN	mkdir /var/run/sshd
COPY	ssh /root/.ssh
COPY	--chown=jenkins:jenkins ssh /home/jenkins/.ssh
RUN     chmod -R 0700 /home/jenkins/.ssh /root/.ssh

# Create directories for slaves with correct file permissions:
RUN	mkdir -p /osmo-gsm-tester-srsue \
                 /osmo-gsm-tester-srsenb \
                 /osmo-gsm-tester-srsepc \
                 /osmo-gsm-tester-trx
RUN	chown -R jenkins:jenkins \
                 /osmo-gsm-tester-srsue \
                 /osmo-gsm-tester-srsenb \
                 /osmo-gsm-tester-srsepc \
                 /osmo-gsm-tester-trx

# Set a UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# We require a newer patchelf for srsue (OS#4389)
ADD     https://nixos.org/releases/patchelf/patchelf-0.10/patchelf-0.10.tar.bz2 /tmp/patchelf-0.10.tar.bz2
RUN     cd /tmp && \
        tar -jxf /tmp/patchelf-0.10.tar.bz2 && \
        cd patchelf-0.10 && \
        ./configure --prefix=/opt && \
        make && \
        mkdir -p /opt/bin/ && \
        cp src/patchelf /opt/bin/patchelf-v0.10

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-gsup-client-dev \
		libosmo-netif-dev \
		libosmo-ranap-dev \
		libosmo-sccp-dev \
		libosmo-sigtran-dev \
		libsmpp34-dev \
		libgtp-dev \
		libasn1c-dev && \
	apt-get clean

# install srsLTE runtime dependencies
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		cmake \
		libfftw3-dev \
		libmbedtls-dev \
		libboost-program-options-dev \
		libconfig++-dev \
		libsctp-dev \
		libpcsclite-dev \
		libuhd-dev \
		libczmq-dev \
		libsoapysdr-dev \
		soapysdr0.7-module-lms7 && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_GSM_TESTER_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-gsm-tester.git
ADD	http://git.osmocom.org/osmo-gsm-tester/patch?h=$OSMO_GSM_TESTER_BRANCH /tmp/commit

RUN	cd osmo-gsm-tester && \
	git fetch && git checkout $OSMO_GSM_TESTER_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_GSM_TESTER_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD

# Copy several scripts and permission for osmo-gsm-tester:
RUN     mkdir -p /usr/local/bin/ && cp osmo-gsm-tester/utils/bin/* /usr/local/bin/
RUN     mkdir -p /etc/sudoers.d/ && cp osmo-gsm-tester/utils/sudoers.d/* /etc/sudoers.d/

VOLUME	/data
COPY	resources.conf /tmp/osmo-gsm-tester/example/resources.conf

ENV   OSMO_GSM_TESTER_CONF /tmp/osmo-gsm-tester/example

WORKDIR	/data
CMD	["/bin/sh", "-c", "/data/osmo-gsm-tester.sh >/data/osmo-gsm-tester.log 2>&1"]

EXPOSE	22/tcp
