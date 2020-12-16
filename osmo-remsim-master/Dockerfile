ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

MAINTAINER Harald Welte <laforge@gnumonks.org>

# PC/SC required for testing of bankd (with vpcd)
# autoconf, automake, libtool, pkg-config, m4, help2man required for virtualsmartcard
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			libpcsclite-dev \
			pcscd \
			pcsc-tools \
			autoconf automake libtool pkg-config m4 help2man ca-certificates && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			pcsc-lite \
			help2man \
			python3 \
		;; \
	esac

# build virtualsmartcard
RUN	git clone https://github.com/frankmorgner/vsmartcard.git
RUN	cd vsmartcard/virtualsmartcard && autoreconf -fi && ./configure && make "-j$(nproc)" install


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
			libosmocore-dev \
			libosmo-simtrace2-dev \
			libosmo-abis-dev \
			libosmo-netif-dev \
			libpcsclite-dev \
			libcsv-dev \
			libjansson-dev \
			libulfius-dev \
			liborcania-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			telnet \
			"pkgconfig(libasn1c)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmosim)" \
			"pkgconfig(libpcsclite)" \
			"pkgconfig(libulfius)" \
			"pkgconfig(libusb-1.0)" \
			"pkgconfig(libosmousb)" \
			"pkgconfig(libosmo-simtrace2)" \
		;; \
	esac

#ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

ARG	OSMO_REMSIM_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-remsim.git
ADD	http://git.osmocom.org/osmo-remsim/patch?h=$OSMO_REMSIM_BRANCH /tmp/commit-osmo-remsim

RUN	cd osmo-remsim && \
	git fetch && git checkout $OSMO_REMSIM_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_REMSIM_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

#COPY	osmo-bts.cfg /data/osmo-bts.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-resmim-server >/data/osmo-resmim-server.log 2>&1"]

#EXPOSE	
