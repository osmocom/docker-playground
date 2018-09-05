ARG	USER
FROM	$USER/debian-jessie-buildslave

RUN	apt-get -y install \
		libffi-dev \
		libgmp-dev \
		libltdl-dev \
		libncurses5-dev \
		libsigsegv-dev \
		libsnmp-dev \
		zip && \
	apt-get clean

RUN	git clone http://git.savannah.gnu.org/r/smalltalk.git
RUN	cd smalltalk && \
	git pull && \
	autoreconf --install --force && \
	./configure && \
	make && \
	make install && \
	cd .. && rm -rf smalltalk

# first clone all repositories so they end up in one cache layer
RUN	git clone https://github.com/zecke/petitparser.git && \
	git clone https://github.com/zecke/petitparser-tests.git && \
	git clone git://git.osmocom.org/smalltalk/osmo-st-logging && \
	git clone git://git.osmocom.org/smalltalk/osmo-st-core && \
	git clone git://git.osmocom.org/smalltalk/osmo-st-network && \
	git clone git://git.osmocom.org/smalltalk/osmo-st-gsm && \
	git clone git://git.osmocom.org/smalltalk/osmo-st-openbsc-test

# now add a file resembling the latest HEAD to invalidate cache once
# upstream git repo changes
ADD	https://api.github.com/repos/zecke/petitparser/git/refs/heads/master /tmp/commit-petitparser
ADD	https://api.github.com/repos/zecke/petitparser-tests/git/refs/heads/master /tmp/commit-petitparser-tests
ADD	http://git.osmocom.org/smalltalk/osmo-st-logging/patch /tmp/commit-osmo-st-logging
ADD	http://git.osmocom.org/smalltalk/osmo-st-core/patch /tmp/commit-osmo-st-core
ADD	http://git.osmocom.org/smalltalk/osmo-st-network/patch /tmp/commit-osmo-st-network
ADD	http://git.osmocom.org/smalltalk/osmo-st-gsm/patch /tmp/commit-osmo-st-gsm
ADD	http://git.osmocom.org/smalltalk/osmo-st-openbsc-test/patch /tmp/commit-osmo-st-openbsc-test

# now build all of them
RUN	cd petitparser && git pull && gst-package package.xml && \
	cd ../petitparser-tests && git pull && gst-package package.xml && \
	cd ../osmo-st-logging && git pull && gst-package package.xml && \
	cd ../osmo-st-core && git pull && gst-package package.xml && \
	cd ../osmo-st-network && git pull && gst-package package.xml && \
	cd ../osmo-st-gsm && git pull && gst-package --test package.xml && \
	cd ../osmo-st-openbsc-test/fakebts && git pull && gst-package --test package.xml
