#!/bin/sh -ex
REPO="network:osmocom:next"
REPO_FILE="$REPO.repo"

# Download repo file
cd /root/yum_repos
if ! [ -e "$REPO_FILE" ]; then
	dnf --setopt=keepcache=1 -y install wget
	wget https://download.opensuse.org/repositories/$REPO/CentOS_8_Stream/$REPO_FILE
fi

# Enable repo
cp "/root/yum_repos/$REPO_FILE" "/etc/yum.repos.d/$REPO_FILE"

# update index
dnf --setopt=keepcache=1 -y check-update /etc/yum.repos.d/$REPO_FILE

# install packages
# somehow -y is not enough
yes | dnf --setopt=keepcache=1 -y install \
	osmo-bsc \
	osmo-bts \
	osmo-ggsn \
	osmo-hlr \
	osmo-iuh \
	osmo-mgw \
	osmo-msc \
	osmo-pcu \
	osmo-sgsn \
	osmo-trx \
	osmo-trx-uhd


bash
