#!/bin/sh -ex
# $1: pkgname
ARCH="x86_64"

cd /home/user/rpmbuild/RPMS

# if already built packages exist, run createrepo and add it as local repo
if [ -d "$ARCH" ]; then
	cd "$ARCH"
	createrepo .

	cat <<- EOF > /etc/yum.repos.d/rpmbuild-local.repo
	[myrepo]
	name=Local Osmocom packages
	baseurl=file:///home/user/rpmbuild/RPMS/$ARCH
	enabled=1
	EOF
fi

# keepcache: /var/cache/dnf is mounted from outside docker dir, so downloaded rpm depends are cached
cd /home/user/rpmbuild/SPECS
dnf \
	--setopt=keepcache=1 \
	-y \
	builddep $1.spec

su user -c "rpmbuild -bb $1.spec"
