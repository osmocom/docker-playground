ARG	USER
FROM	$USER/debian-jessie-build


RUN	[ "$(arch)" = "x86_64" ] && dpkg --add-architecture i386; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		asciidoc \
		bc \
		bzip2 \
		coccinelle \
		dahdi-source \
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

RUN	useradd -m --uid=1000 build && \
	echo "build ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/build && \
	chmod 0440 /etc/sudoers.d/build && \
	mkdir /build && \
	chown build:build /build

RUN	pip install timeout_decorator && \
	pip install bumpversion

# first add this file to invalidate cache each time osmo-python-tests.git is updated
ADD	http://git.osmocom.org/python/osmo-python-tests/patch /tmp/commit-osmo-python-tests
RUN	git clone git://git.osmocom.org/python/osmo-python-tests && \
	cd osmo-python-tests && \
	python2 ./setup.py install
