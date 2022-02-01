ARG	USER
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=almalinux:8
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# dnf-utils: for repoquery
RUN	dnf install -y \
		systemd \
		dnf-utils

# Make additional development libraries available
RUN	yum config-manager --set-enabled powertools
