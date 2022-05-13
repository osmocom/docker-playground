ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=almalinux:8
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	DISTRO


# set up systemd
# container=docker: systemd likes to know it is running inside a container
ENV container docker
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends systemd; \
			(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do test "$i" = "systemd-tmpfiles-setup.service" || rm -f $i; done); \
			rm -f /lib/systemd/system/multi-user.target.wants/*; \
			rm -f /etc/systemd/system/*.wants/*; \
			rm -f /lib/systemd/system/local-fs.target.wants/*; \
			rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
			rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
			rm -f /lib/systemd/system/basic.target.wants/*; \
			rm -f /lib/systemd/system/anaconda.target.wants/*; \
		;; \
	centos*) \
		yum -y install systemd; yum clean all; \
			(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do test "$i" = "systemd-tmpfiles-setup.service" || rm -f $i; done); \
			rm -f /lib/systemd/system/multi-user.target.wants/*; \
			rm -f /etc/systemd/system/*.wants/*; \
			rm -f /lib/systemd/system/local-fs.target.wants/*; \
			rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
			rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
			rm -f /lib/systemd/system/basic.target.wants/*; \
			rm -f /lib/systemd/system/anaconda.target.wants/*; \
		;; \
	esac
VOLUME [ "/sys/fs/cgroup" ]

#RUN	systemctl enable osmo-bsc osmo-bts-trx osmo-mgw osmo-pcu

CMD	["/lib/systemd/systemd", "--system", "--unit=multi-user.target"]
