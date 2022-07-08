ARG	USER
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:bullseye
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# ca-certificates: needed for limesuite-images post-install script

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		aptitude \
		ca-certificates \
		gnupg \
		systemd
