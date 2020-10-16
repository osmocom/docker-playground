ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/"

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
ADD	http://download.opensuse.org/repositories/network:/osmocom:/nightly/CentOS_8_Stream/repodata/repomd.xml /tmp/repomd.xml
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			telnet \
			libosmocore-dev \
			libosmo-netif-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			telnet \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/data

ARG	OSMO_STP_BRANCH="master"

RUN	git clone git://git.osmocom.org/libosmo-sccp.git
ADD	http://git.osmocom.org/libosmo-sccp/patch?h=$OSMO_STP_BRANCH /tmp/commit
RUN	cd libosmo-sccp && \
	git fetch && git checkout $OSMO_STP_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_STP_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	install examples/.libs/sccp_demo_user /usr/local/bin/ && \
	ldconfig

VOLUME	/data

COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
