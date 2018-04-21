FROM neels/osmo-nitb-master

MAINTAINER Neels Hofmeyr <neels@hofmeyr.de>

RUN	apt-get install -y unzip
RUN	wget --no-check-certificate -O /tmp/websocketd.zip https://github.com/joewalnes/websocketd/releases/download/v0.3.0/websocketd-0.3.0-linux_amd64.zip
RUN	mkdir /websocketd \
	&& cd /websocketd \
	&& unzip /tmp/websocketd.zip

RUN	cd / \
	&& git clone git://github.com/whyteks/meas_web

RUN	apt-get install -y tcpdump
RUN	apt-get install -y netcat6

WORKDIR /
CMD	/websocketd/websocketd --staticdir=/meas_web/usr/share/fairwaves-meas-web --port=80 /usr/bin/stdbuf -oL meas_json
