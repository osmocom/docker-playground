FROM	debian:stable

LABEL	name="dnsmasq" \
	description="Dnsmasq Server" \
	version="1.0" \
	maintainer="pespin@sysmocom.de"

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		dnsmasq && \
	apt-get clean

EXPOSE	53/tcp \
	53/udp

VOLUME	/etc/dnsmasq

CMD	["/bin/sh", "-c", "dnsmasq -d --log-queries=extra -C /data/dnsmasq.conf >/data/dnsmasq.log 2>&1"]
