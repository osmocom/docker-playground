FROM	laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	dpkg --add-architecture i386 && \
	apt-get install -y --no-install-recommends \
		asciidoc \
		bc \
		bzip2 \
		coccinelle \
		htop \
		mscgen \
		openssh-client \
		python \
		python-pip \
		python3 \
		python-minimal \
		rsync \
		sudo \
		texinfo \
		unzip && \
	apt-get clean

RUN	useradd --uid=1000 build && \
	mkdir /build && \
	chown build:build /build

RUN	pip install timeout_decorator

# first add this file to invalidate cache each time osmo-python-tests.git is updated
ADD	http://git.osmocom.org/python/osmo-python-tests/patch /tmp/commit-osmo-python-tests
RUN	git clone git://git.osmocom.org/python/osmo-python-tests && \
	cd osmo-python-tests && \
	python2 ./setup.py install
