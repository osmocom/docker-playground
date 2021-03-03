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
	cd /etc/yum.repos.d/ && \
	wget $OSMOCOM_REPO_MIRROR/repositories/network:osmocom:latest/CentOS_8/network:osmocom:latest.repo

RUN	dnf install -y \
		telnet

# Invalidate cache once the repository is updated
ADD	$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/latest/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
