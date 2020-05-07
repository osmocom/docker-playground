#!/bin/sh -ex
# $1: pkgname

cd /home/user/rpmbuild/SPECS

# keepcache: /var/cache/dnf is mounted from outside docker dir, so downloaded rpm depends are cached
dnf \
	--setopt=keepcache=1 \
	-y \
	builddep $1.spec

su user -c "rpmbuild -bb $1.spec"
