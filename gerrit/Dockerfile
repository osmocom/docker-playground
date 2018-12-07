FROM gerritcodereview/gerrit

USER root
RUN yum -y install zip unzip patch

RUN \
	unzip /var/gerrit/bin/gerrit.war WEB-INF/lib/com_google_gerrit_httpd_auth_openid_libopenid.jar && \
	unzip WEB-INF/lib/com_google_gerrit_httpd_auth_openid_libopenid.jar com/google/gerrit/httpd/auth/openid/LoginForm.html

COPY add_osmocom.diff /tmp
RUN patch -p0 < /tmp/add_osmocom.diff

RUN \
	zip -u WEB-INF/lib/com_google_gerrit_httpd_auth_openid_libopenid.jar com/google/gerrit/httpd/auth/openid/LoginForm.html && \
	zip -u /var/gerrit/bin/gerrit.war WEB-INF/lib/com_google_gerrit_httpd_auth_openid_libopenid.jar

USER gerrit

