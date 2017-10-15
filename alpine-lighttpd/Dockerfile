FROM		alpine:latest
MAINTAINER 	Harald Welte <laforge@gnumonks.org>

EXPOSE		80

RUN		apk --update add lighttpd && \
		rm -rf /var/cache/apk/* && \
		mkdir -p /etc/lighttpd/lighttpd.conf.d && \
		touch /etc/lighttpd/lighttpd.conf.d/empty && \
		echo 'include_shell "cat /etc/lighttpd/lighttpd.conf.d/*"' >> /etc/lighttpd/lighttpd.conf
		
VOLUME		/etc/lighttpd/lighttpd.conf.d
COPY		ipv6.conf /etc/lighttpd/lighttpd.conf.d/

VOLUME		/var/www/localhost/htdocs
COPY		index.html /var/www/localhost/htdocs/


CMD 		["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
