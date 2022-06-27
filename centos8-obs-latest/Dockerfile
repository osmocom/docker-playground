ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=almalinux:8
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO_VERSION="latest"

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Make additional development libraries available from PowerTools and set up
# Osmocom OBS repository
RUN	dnf install -y dnf-utils wget && \
	yum config-manager --set-enabled powertools && \
	export MIRROR_HTTPS="$(echo $OSMOCOM_REPO_MIRROR | sed s/^http:/https:/)" && \
	{ echo "[network_osmocom_${OSMOCOM_REPO_VERSION}]"; \
	  echo "name=Osmocom ${OSMOCOM_REPO_VERSION}"; \
	  echo "type=rpm-md"; \
	  echo "baseurl=${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_8/"; \
	  echo "gpgcheck=1"; \
	  echo "gpgkey=${MIRROR_HTTPS}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_8/repodata/repomd.xml.key"; \
	  echo "enabled=1"; \
	} > "/etc/yum.repos.d/network:osmocom:${OSMOCOM_REPO_VERSION}.repo"

RUN	dnf install -y \
		telnet

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

# Invalidate cache once the repository is updated
ADD	${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
