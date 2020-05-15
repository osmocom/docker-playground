#!/bin/sh -ex
distfiles="/home/user/distfiles/$1"

# Download missing sources
mkdir -p "$distfiles"
spectool -C "$distfiles" -gf $1.spec

# Copy downloaded/cached source files to SOURCES
for i in "$distfiles/"*; do
	[ -e "$i" ] || continue

	cp "$i" "/home/user/rpmbuild/SOURCES/"
done


# Print expanded spec file
rpmspec -P $1.spec

# Build the package
rpmbuild -bb $1.spec
