ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	case "$DISTRO" in \
	debian*) \
		apt-key add /tmp/Release.key && \
		rm /tmp/Release.key && \
		echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list \
		;; \
	esac

# we need to add this to invalidate the cache once the repository is updated.
# unfortunately Dockerfiles don't support a conditional ARG, so we need to add both DPKG + RPM
ADD	$OSMOCOM_REPO/Release /tmp/Release
ADD	$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/nightly/CentOS_8/repodata/repomd.xml /tmp/repomd.xml
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			telnet \
			libosmocore-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			telnet \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
			"pkgconfig(libosmoctrl)" \
		;; \
	esac

ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

ARG	OSMO_PCU_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-pcu.git
ADD	http://git.osmocom.org/osmo-pcu/patch?h=$OSMO_PCU_BRANCH /tmp/commit-osmo-pcu

RUN	cd osmo-pcu && \
	git fetch && git checkout $OSMO_PCU_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_PCU_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-pcu", "-i", "172.18.0.230"]

#EXPOSE
