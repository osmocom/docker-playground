ARG	USER
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:stretch
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

COPY	Release.key /tmp/Release.key

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		aptitude \
		gnupg \
		systemd && \
	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key
