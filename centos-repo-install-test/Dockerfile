ARG	USER
FROM	centos:centos8

# dnf-utils: for repoquery
RUN	dnf install -y \
		systemd \
		dnf-utils

# Make additional development libraries available
RUN	yum config-manager --set-enabled PowerTools

