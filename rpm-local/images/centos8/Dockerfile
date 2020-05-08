FROM	centos:centos8
ARG	UID

RUN	useradd -m --uid=$UID user

# dnf-plugins-core: for "dnf builddep"
# rpmdevtools: for "spectool"
# make, gcc: I was told that they should be in BuildRequires in #rpm.org @ freenode, however even the spec files taken
#            directly from fedora implicitly depend on make it seems, so just add them in the build env.
RUN	dnf install -y \
		createrepo \
		dnf-plugins-core \
		gcc \
		make \
		rpm-build \
		rpmdevtools

# enable repository with required -devel packages
RUN	yum config-manager --set-enabled PowerTools
