# Image for building Android apps (android-apdu-proxy)
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bookworm
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	UID

RUN	useradd --uid=${UID} -d /build -m build

RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		android-sdk \
		sdkmanager \
		&& \
	apt-get clean

ENV	ANDROID_HOME=/usr/lib/android-sdk/

RUN	set -x && \
	sdkmanager 'platforms;android-34' && \
	sdkmanager 'build-tools;34.0.0' && \
	yes | sdkmanager --licenses
