#!/bin/sh -e
DIR="$(cd "$(dirname "$0")" && pwd -P)"
OBSSRC=~/code/obs
PROJ=openSUSE:Factory
PKGNAME="$1"

if [ -z "$PKGNAME" ]; then
	echo "usage: $(basename $0) PKGNAME"
	exit 1
fi

set -x
cd "$OBSSRC"
if ! [ -e "$PROJ/$PKGNAME" ]; then
	osc co "$PROJ" "$PKGNAME"
fi

cd "$DIR/spec"
if [ -d "$PKGNAME" ]; then
	rm -r "$PKGNAME"
fi

mkdir "$PKGNAME"
cd "$PKGNAME"
cp -v "$OBSSRC/$PROJ/$PKGNAME/"* .

cd "$DIR"
./obs-clean.sh
