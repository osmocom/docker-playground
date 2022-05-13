# See https://fairwaves.co/blog/openbts-umts-3g-umtrx/

# Ancient software requires ancient distro
FROM	debian:jessie


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
			   --no-install-suggests \
		ca-certificates \
		build-essential \
		pkg-config \
		debhelper \
		automake \
		autoconf \
		libtool-bin \
		libtool \
		unzip \
		wget \
		git \
		libboost-dev \
		libreadline6-dev \
		libusb-1.0-0-dev \
		libsqlite3-dev \
		libosip2-dev \
		libortp-dev \
		libzmq3-dev \
		python-zmq \
		libuhd-dev

WORKDIR	/home/root

# Download and install UHD firmware
ARG	UHD_RELEASE="003.007.003"
RUN	wget http://files.ettus.com/binaries/maint_images/archive/uhd-images_$UHD_RELEASE-release.zip && \
		unzip uhd-images_$UHD_RELEASE-release.zip && \
		cp -r uhd-images_$UHD_RELEASE-release/share/uhd/ /usr/share/

# Install asn1c
ARG	ASN1C_COMMIT="80b3752c8093251a1ef924097e9894404af2d304"
RUN	git clone https://github.com/vlm/asn1c.git
RUN	cd asn1c && \
		git checkout $ASN1C_COMMIT && \
		./configure && \
		make install

# Install libcoredumper
RUN	git clone https://github.com/RangeNetworks/libcoredumper.git
RUN	cd libcoredumper && \
		./build.sh && \
		dpkg -i libcoredumper*.deb

# Finally, install OpenBTS-UMTS
RUN	git clone https://github.com/RangeNetworks/OpenBTS-UMTS.git
RUN	cd OpenBTS-UMTS && \
		git submodule init && \
		git submodule update && \
		./autogen.sh && \
		./configure && \
		make install && \
		make clean

CMD	cd /OpenBTS/ && ./OpenBTS-UMTS
