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
		[osmocom-$arch]
		name=Local Osmocom packages ($arch)
		baseurl=file:///home/user/rpmbuild/RPMS/$arch
		enabled=1
		gpgcheck=0
		EOF

		cd ..
	fi
done

# Remove local repo related cache
rm -rf /var/cache/dnf/osmocom*

cd /home/user/rpmbuild/SPECS

# Install systemd-rpm-macros if needed, so the .spec can be parsed
if grep "^BuildRequires:" "$1.spec" | grep -q systemd-rpm-macros; then
	dnf -y install systemd-rpm-macros
fi

# keepcache: /var/cache/dnf is mounted from outside docker dir, so downloaded rpm depends are cached
dnf \
	--setopt=keepcache=1 \
	-y \
	builddep $1.spec

# Macros that are expected to be in the OBS prjconf
# https://en.opensuse.org/openSUSE:Build_Service_cross_distribution_howto#Install_man_files
# Without this, osmo-ggsn fails to build
cat << EOF >> /etc/rpm/macros.dist
# like OBS prjconf
%ext_info .gz
%ext_man .gz
EOF

# Continue building as user
su user -c "/scripts/build_pkg_user.sh $1"
