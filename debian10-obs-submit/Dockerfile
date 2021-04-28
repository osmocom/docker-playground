# Used by osmo-ci.git scripts/osmocom-packages-docker.sh
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:buster
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	UID

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		debhelper \
		devscripts \
		dpkg-dev \
		git \
		git-buildpackage \
		meson \
		osc \
		patch \
		sed \
		&& \
	apt-get clean

RUN	useradd --uid=${UID} -m user
USER	user
RUN	git config --global user.email "obs-submit@docker" && \
	git config --global user.name "obs-submit"
