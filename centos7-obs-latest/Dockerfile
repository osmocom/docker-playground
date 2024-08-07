ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=centos:centos7
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO_VERSION="latest"

# Use vault.centos.org instead of mirrorlist.centos.org, which doesn't exist
# anymore (see https://serverfault.com/a/1161847).
RUN	set -x && \
	sed -i 's/mirror.centos.org/vault.centos.org/g' /etc/yum.repos.d/*.repo && \
	sed -i 's/^#.*baseurl=http/baseurl=http/g' /etc/yum.repos.d/*.repo && \
	sed -i 's/^mirrorlist=http/#mirrorlist=http/g' /etc/yum.repos.d/*.repo

# Use dnf package manager instead of yum, so we can use all the dnf codepaths
# that were originally written for CentOS8 in this CentOS7 image too
RUN	yum install -y dnf

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Set up Osmocom OBS repository
RUN	export MIRROR_HTTPS="$(echo $OSMOCOM_REPO_MIRROR | sed s/^http:/https:/)" && \
	{ echo "[network_osmocom_${OSMOCOM_REPO_VERSION}]"; \
	  echo "name=Osmocom ${OSMOCOM_REPO_VERSION}"; \
	  echo "type=rpm-md"; \
	  echo "baseurl=${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_7/"; \
	  echo "gpgcheck=1"; \
	  echo "gpgkey=${MIRROR_HTTPS}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_7/repodata/repomd.xml.key"; \
	  echo "enabled=1"; \
	} > "/etc/yum.repos.d/network:osmocom:${OSMOCOM_REPO_VERSION}.repo"

RUN	dnf install -y \
		telnet

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

# Invalidate cache once the repository is updated
ADD	${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}/CentOS_7/repodata/repomd.xml /tmp/repomd.xml
