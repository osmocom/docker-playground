ARG	USER
FROM	$USER/debian-buster-jenkins
ARG	OGT_MASTER_ADDR="172.18.50.2"


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
		python3-watchdog \
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
		pysispm \
		pymongo

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
                 /osmo-gsm-tester-trx \
		 /osmo-gsm-tester-grbroker \
		 /osmo-gsm-tester-open5gs
RUN	chown -R jenkins:jenkins \
                 /osmo-gsm-tester-*

# Set a UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# We require a newer patchelf 0.11 (OS#4389)
ADD     https://github.com/NixOS/patchelf/archive/0.11.tar.gz /tmp/patchelf-0.11.tar.gz
RUN     cd /tmp && \
        tar -zxf /tmp/patchelf-0.11.tar.gz && \
        cd patchelf-0.11 && \
	autoreconf -fi && \
        ./configure --prefix=/usr/local && \
        make && \
        make install

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

# install srsRAN runtime dependencies
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
		soapysdr-module-lms7 && \
	apt-get clean

# install gnuradio runtime dependencies
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		gnuradio && \
	apt-get clean

# install open5gs dependencies: (mongodb not available in Debian)
# systemctl stuff: workaround for https://jira.mongodb.org/browse/SERVER-54386
ADD	https://www.mongodb.org/static/pgp/server-4.4.asc /tmp/mongodb-server-4.4.asc
RUN	if [ "$(arch)" = "x86_64" ]; then \
		apt-key add /tmp/mongodb-server-4.4.asc && \
		echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" \
			> /etc/apt/sources.list.d/mongodb-org-4.4.list; \
	fi
RUN	if [ "$(arch)" = "x86_64" ]; then \
		apt-get update && \
		systemctl_path=$(which systemctl) && \
		mv $systemctl_path /tmp/systemctl && \
		apt-get install -y --no-install-recommends mongodb-org && \
		apt-get clean && \
		mv /tmp/systemctl $systemctl_path && \
		sed -i "s/127.0.0.1/$OGT_MASTER_ADDR/g" /etc/mongod.conf; \
	fi

# install open5gs dependencies:
RUN	if [ "$(arch)" = "x86_64" ]; then \
		apt-get update && \
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
			libnghttp2-dev \
			libmicrohttpd-dev \
			libcurl4-gnutls-dev \
			libnghttp2-dev \
			meson && \
		apt-get clean; \
	fi

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
RUN     mkdir -p /etc/security/limits.d/ && cp osmo-gsm-tester/utils/limits.d/* /etc/security/limits.d/

VOLUME	/data
COPY	resources.conf /tmp/osmo-gsm-tester/sysmocom/resources.conf

WORKDIR	/data
CMD	["/bin/sh", "-c", "/data/osmo-gsm-tester-master.sh >/data/osmo-gsm-tester.log 2>&1"]

EXPOSE	22/tcp
