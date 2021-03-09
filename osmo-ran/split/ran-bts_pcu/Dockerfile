ARG     USER
FROM	$USER/systemd
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
ARG	OSMOCOM_REPO_VERSION=latest

MAINTAINER Pau Espin Pedrol <pespin@sysmocom.de>

ARG	OSMOCOM_REPO_DEBIAN="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/$OSMOCOM_REPO_VERSION/Debian_9.0/"
ARG	OSMOCOM_REPO_CENTOS="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/$OSMOCOM_REPO_VERSION/CentOS_8/"

COPY	.common/Release.key /tmp/Release.key

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			gnupg && \
		apt-key add /tmp/Release.key && \
		rm /tmp/Release.key && \
		echo "deb " $OSMOCOM_REPO_DEBIAN " ./" > /etc/apt/sources.list.d/osmocom-$OSMOCOM_REPO_VERSION.list \
		;; \
	centos*) \
		echo "metadata_expire=60" >> /etc/dnf/dnf.conf && cat /etc/dnf/dnf.conf && \
		dnf install -y dnf-utils wget && \
		yum config-manager --set-enabled PowerTools && \
		cd /etc/yum.repos.d/ && \
		wget ${OSMOCOM_REPO_CENTOS}/network:osmocom:$OSMOCOM_REPO_VERSION.repo \
		;; \
	esac

# we need to add this to invalidate the cache once the repository is updated.
# unfortunately Dockerfiles don't support a conditional ARG, so we need to add both DPKG + RPM
ADD	$OSMOCOM_REPO_DEBIAN/Release /tmp/Release
ADD	$OSMOCOM_REPO_CENTOS/repodata/repomd.xml /tmp/repomd.xml

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			less \
			apt-utils \
			strace \
			tcpdump \
			telnet \
			vim \
			osmo-bts-trx \
			osmo-pcu && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			less \
			strace \
			tcpdump \
			telnet \
			vim \
			osmo-bts \
			osmo-pcu \
		;; \
	esac

RUN	systemctl enable osmo-bts-trx osmo-pcu

WORKDIR	/tmp
RUN	cp -r /etc/osmocom /etc/osmocom-default
VOLUME	/data
VOLUME	/etc/osmocom

COPY	osmocom/* /etc/osmocom/

CMD	["/lib/systemd/systemd", "--system", "--unit=multi-user.target"]

#osmo-bts: VTY  CTRL
EXPOSE     4241 4238
#osmo-pcu: VTY  CTRL
EXPOSE     4240
