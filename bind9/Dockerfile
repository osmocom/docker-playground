FROM	debian:stable

LABEL	name="bind9" \
	description="Bind9 DNS server" \
	version="1.0" \
	maintainer="laforge@gnumonks.org"

RUN	apt-get update && \
	apt-get install -y \
		bind9 \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /run/named \
	&& chown bind:bind /run/named

EXPOSE	53/tcp \
	53/udp

VOLUME	/etc/named

ENTRYPOINT  ["/usr/sbin/named", "-c", "/etc/named/named.conf", "-u", "bind", "-g"]
