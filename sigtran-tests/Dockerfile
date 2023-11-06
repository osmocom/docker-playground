ARG	USER
# needs buster as the code *really* requires old guile-2.0
# which is not available in more modern distributions, see
# https://github.com/nplab/m3ua-testtool/issues/2 for more info
FROM	$USER/debian-buster-build


RUN	apt-get update && apt-get -y install		\
		guile-2.0 guile-2.0-dev gnulib tcsh \
		python3 python3-pip

RUN	pip3 install junit-xml

RUN	cd /tmp && git clone https://github.com/nplab/guile-sctp && \
	cd guile-sctp && \
	./bootstrap && \
	./configure && \
	make && \
	make install
