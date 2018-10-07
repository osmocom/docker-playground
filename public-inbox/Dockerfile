FROM	debian:stable

ENV	DEBIAN_FRONTEND noninteractive

RUN	apt-get update && \
	apt-get -y install \
		git libtimedate-perl libemail-mime-perl libemail-mime-contenttype-perl \
		make perl libplack-perl libmail-thread-perl liburi-perl libdanga-socket-perl \
		libnet-server-perl libsearch-xapian-perl libdbi-perl libdbd-sqlite3-perl

RUN	git clone https://public-inbox.org ~/public-inbox && \
	cd ~/public-inbox && \
	perl Makefile.PL && \
	make && \
	make install && \
	rm -rf ~/public-inbox

CMD	(cd /srv; for NAME in *; do CONF="/srv/${NAME}/config"; public-inbox-init "${NAME}" "/srv/${NAME}" $(git config -f "${CONF}" publicinbox.http) $(git config -f "${CONF}" publicinbox.email); done) && public-inbox-index /srv/* && public-inbox-httpd

EXPOSE 8080
