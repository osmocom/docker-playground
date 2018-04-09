
network_create() {
	NET=$1
	echo Creating network $NET_NAME
	docker network create --internal --subnet $NET $NET_NAME
}

network_remove() {
	echo Removing network $NET_NAME
	docker network remove $NET_NAME
}



set -x

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

# non-jenkins execution: put logs in /tmp
if [ "x$BUILD_TAG" = "x" ]; then
	BUILD_TAG=nonjenkins
fi

SUITE_NAME=`basename $PWD`

NET_NAME=$SUITE_NAME

VOL_BASE_DIR=`mktemp -d`

rm -rf $WORKSPACE/logs || /bin/true
mkdir -p $WORKSPACE/logs
