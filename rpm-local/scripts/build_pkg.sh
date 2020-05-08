#!/bin/sh -ex
# $1: pkgname
ARCHES="x86_64 noarch"

cd /home/user/rpmbuild/RPMS

# if already built packages exist, run createrepo and add it as local repo
for arch in $ARCHES; do
	if [ -d "$arch" ]; then
		cd "$arch"
		createrepo .
	
		cat <<- EOF > /etc/yum.repos.d/rpmbuild-local-$arch.repo
		[myrepo-$arch]
		name=Local Osmocom packages ($arch)
		baseurl=file:///home/user/rpmbuild/RPMS/$arch
		enabled=1
		gpgcheck=0
		EOF

		cd ..
	fi
done

# HACK: install systemd-rpm-macros unless we are building it now, so the spec files can be parsed
if [ "$1" != "systemd-rpm-macros" ]; then
	dnf -y install systemd-rpm-macros
fi

# keepcache: /var/cache/dnf is mounted from outside docker dir, so downloaded rpm depends are cached
cd /home/user/rpmbuild/SPECS
dnf \
	--setopt=keepcache=1 \
	-y \
	builddep $1.spec

# Continue building as user
su user -c "/scripts/build_pkg_user.sh $1"
