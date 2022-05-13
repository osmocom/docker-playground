ARG	REGISTRY=docker.io
ARG	USER
FROM 	$USER/debian-bullseye-build


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		gnuradio-dev \
		gr-osmosdr \
		cmake \
		swig

ARG	GR_GSM_BRANCH="master"

RUN	git clone git://git.osmocom.org/gr-gsm
ADD     http://git.osmocom.org/gr-gsm/patch?h=$GR_GSM_BRANCH /tmp/commit-gr-gsm

RUN	cd gr-gsm \
	&& git fetch && git checkout -f -B $GR_GSM_BRANCH origin/$GR_GSM_BRANCH \
	&& git rev-parse --abbrev-ref HEAD && git rev-parse HEAD \
	&& mkdir build/ \
	&& cd build/ \
	&& cmake .. \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-Wno-dev \
	&& make "-j$(nproc)" \
	&& make install
