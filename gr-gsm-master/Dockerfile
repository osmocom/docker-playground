ARG 	REGISTRY=docker.io
FROM 	${REGISTRY}/archlinux/base

MAINTAINER Vadim Yanitskiy <axilirator@gmail.com>

ARG	LIBOSMOCORE_BRANCH="master"
ARG	GR_GSM_BRANCH="master"

# Build dependencies
ENV	BUILD_DEPS \
	automake \
	autoconf \
	libtool \
	pkgconf \
	cmake \
	make \
	swig \
	gcc

# Sync pacman
RUN	pacman -Syyu --noconfirm

# Install persistent packages
RUN	pacman -S --needed --noconfirm \
		gnuradio \
		python2 \
		python2-scipy \
		python2-requests \
		talloc \
		boost

# Download USRP firmware
RUN	uhd_images_downloader

# Install build dependencies
RUN	pacman -S --needed --noconfirm \
	$BUILD_DEPS

# Make Python2 default
RUN	ln -s /usr/bin/python2 /usr/bin/python

# Install and configure git
RUN	pacman -S --needed --noconfirm git \
	&& git config --global user.email docker@dock.er \
	&& git config --global user.name "Dock Er"

WORKDIR	/tmp

# Download, build and install libosmocore
RUN	git clone git://git.osmocom.org/libosmocore
ADD	http://git.osmocom.org/libosmocore/patch?h=$LIBOSMOCORE_BRANCH /tmp/commit-libosmocore

RUN	cd libosmocore \
	&& git fetch && git checkout -f -B $LIBOSMOCORE_BRANCH origin/$LIBOSMOCORE_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& autoreconf -fi \
	&& ./configure \
		--disable-doxygen \
		--disable-pcsc \
		--prefix=/usr \
	&& make "-j$(nproc)" \
	&& make install \
	&& make distclean

RUN	git clone git://git.osmocom.org/gr-gsm
ADD     http://git.osmocom.org/gr-gsm/patch?h=$GR_GSM_BRANCH /tmp/commit-gr-gsm

RUN	cd gr-gsm \
	&& git fetch && git checkout -f -B $GR_GSM_BRANCH origin/$GR_GSM_BRANCH \
	&& git rev-parse HEAD \
	&& mkdir build/ \
	&& cd build/ \
	&& cmake \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-Wno-dev \
		-DENABLE_GRCC=OFF \
		../ \
	&& make "-j$(nproc)" \
	&& make install \
	&& cd ../ \
	&& rm -rf build/

# Remove build dependencies
RUN	pacman -Rs --noconfirm \
	$BUILD_DEPS
