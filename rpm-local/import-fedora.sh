#!/bin/sh -e
DIR="$(cd "$(dirname "$0")" && pwd -P)"
FEDORASRC=~/code/fedora
BRANCH=f31
PKGNAME="$1"

if [ -z "$PKGNAME" ]; then
	echo "usage: $(basename $0) PKGNAME"
	exit 1
fi

set -x
cd "$FEDORASRC"
if ! [ -e "$PKGNAME" ]; then
	git clone "https://src.fedoraproject.org/rpms/$PKGNAME"
fi
cd "$PKGNAME"
git checkout "$BRANCH"

cd "$DIR/spec"
if [ -d "$PKGNAME" ]; then
	rm -r "$PKGNAME"
fi

mkdir "$PKGNAME"
cd "$PKGNAME"
cp -v "$FEDORASRC/$PKGNAME/"* .
