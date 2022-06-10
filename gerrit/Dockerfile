FROM gerritcodereview/gerrit:3.4.5

USER root
RUN yum -y install zip unzip patch

# Patch LoginForm.html (unpack and repack from gerrit.war)
ARG gerritwar="/var/gerrit/bin/gerrit.war"
ARG libopenid="WEB-INF/lib/com_google_gerrit_httpd_auth_openid_libopenid.jar"
ARG loginform="com/google/gerrit/httpd/auth/openid/LoginForm.html"

RUN \
	unzip "$gerritwar" "$libopenid" && \
	unzip "$libopenid" "$loginform"

COPY add_osmocom.diff /tmp
RUN patch -p0 < /tmp/add_osmocom.diff

RUN \
	zip -u "$libopenid" "$loginform" && \
	zip -u "$gerritwar" "$libopenid"

USER gerrit

