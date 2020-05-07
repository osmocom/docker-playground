FROM	centos:centos8
ARG	UID

RUN	useradd -m --uid=$UID user

# dnf-plugins-core: for "dnf builddep"
RUN	dnf install -y \
		createrepo \
		dnf-plugins-core \
		rpm-build

# enable repository with required -devel packages
RUN	yum config-manager --set-enabled PowerTools
