# Used by pysim master and gerrit jobs
ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:trixie
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

# Arguments used after FROM must be specified again
ARG	UID

# Configure build user
RUN	useradd --uid=${UID} -d /build -m build

# Install packages from Debian repositories (alphabetic order)
RUN	set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gcc \
		ghostscript \
		git \
		latexmk \
		libpcsclite-dev \
		make \
		openssh-client \
		pylint \
		python3-dev \
		python3-pip \
		python3-virtualenv \
		rsync \
		tex-gyre \
		texlive-latex-extra \
		texlive-latex-recommended \
		tshark \
		&& \
	apt-get clean

# Install osmo-ci.git/scripts to /usr/local/bin
ADD	https://gerrit.osmocom.org/plugins/gitiles/osmo-ci/+/master?format=TEXT /tmp/osmo-ci-commit
RUN 	set -x && \
	git clone --depth=1 https://gerrit.osmocom.org/osmo-ci osmo-ci && \
	cp -v osmo-ci/scripts/*.* /usr/local/bin && \
	rm -rf osmo-ci

# Install pip dependencies (alphabetic order)
# break-system-packages: inside docker it's fine to install pkgs system-wide
# lcov-to-cobertura-xml: use this commit as the latest version fails:
#                        https://github.com/eriwen/lcov-to-cobertura-xml/issues/63
ADD	https://gitea.osmocom.org/sim-card/pysim/raw/branch/master/requirements.txt /tmp/pysim_requirements.txt
RUN	set -x && \
	cat /tmp/pysim_requirements.txt && \
	pip3 install --break-system-packages \
		'git+https://github.com/eriwen/lcov-to-cobertura-xml.git@028da3798355d0260c6c6491b39347d84ca7a02d' \
		'git+https://github.com/osmocom/sphinx-argparse@inside-classes#egg=sphinx-argparse' \
		'git+https://github.com/podshumok/python-smpplib.git' \
		'pyshark' \
		'sphinx' \
		'sphinxcontrib-napoleon' \
		-r /tmp/pysim_requirements.txt
