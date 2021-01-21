ARG	USER
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:stretch
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		aptitude \
		gnupg \
		systemd
