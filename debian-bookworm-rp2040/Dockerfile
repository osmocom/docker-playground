# Container for building osmo-rp2040-firmware
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
ARG	UID
ARG	PICO_SDK_VERSION=2.1.1
ARG	PICO_TOOL_VERSION=2.1.1

# For CMake
ENV	PICO_SDK_PATH=/opt/pico-sdk

# Add the build user
RUN	useradd --uid=${UID} -m build && \
	mkdir /build && \
	chown -R build:build /build /opt /usr/local

# Install required packages, based on:
# https://github.com/raspberrypi/pico-sdk?tab=readme-ov-file#unix-command-line
# https://github.com/raspberrypi/picotool?tab=readme-ov-file#linux--macos
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		cmake \
		gcc-arm-none-eabi \
		git \
		libnewlib-arm-none-eabi \
		libstdc++-arm-none-eabi-newlib \
		libusb-1.0-0-dev \
		pkg-config \
		python3 \
	&& \
	apt-get clean

USER	build

# Install the SDK
RUN	set -x && \
	cd /opt && \
	git clone --depth=1 https://github.com/raspberrypi/pico-sdk -b "${PICO_SDK_VERSION}" && \
	cd pico-sdk && \
	git submodule update --init --depth 1

# Build and install picotool
RUN	set -x && \
	cd /opt && \
	git clone --depth=1 https://github.com/raspberrypi/picotool -b "${PICO_TOOL_VERSION}" && \
	cd picotool && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
	make -j$(nproc) install
