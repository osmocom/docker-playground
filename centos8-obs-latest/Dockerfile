ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=centos:centos8
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

# Let package metadata expire after 60 seconds instead of 48 hours
RUN	echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf

# Make additional development libraries available from PowerTools and set up
# Osmocom latest OBS repository
RUN	dnf install -y dnf-utils wget && \
	yum config-manager --set-enabled powertools && \
	export MIRROR_HTTPS="$(echo $OSMOCOM_REPO_MIRROR | sed s/^http:/https:/)" && \
	{ echo "[network_osmocom_latest]"; \
	  echo "name=Latest tagged versions of osmocom cellular network elements (CentOS_8)"; \
	  echo "type=rpm-md"; \
	  echo "baseurl=${OSMOCOM_REPO_MIRROR}/repositories/network:/osmocom:/latest/CentOS_8/"; \
	  echo "gpgcheck=1"; \
	  echo "gpgkey=${MIRROR_HTTPS}/repositories/network:/osmocom:/latest/CentOS_8/repodata/repomd.xml.key"; \
	  echo "enabled=1"; \
	} > /etc/yum.repos.d/network:osmocom:latest.repo

RUN	dnf install -y \
		telnet

# Make respawn.sh part of this image, so it can be used by other images based on it
COPY	.common/respawn.sh /usr/local/bin/respawn.sh

# Invalidate cache once the repository is updated
ADD	$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/latest/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
