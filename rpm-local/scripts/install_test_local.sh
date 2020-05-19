#!/bin/sh -ex
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

dnf --setopt=keepcache=1 -y install osmo-trx-uhd osmo-trx-ipc

bash
