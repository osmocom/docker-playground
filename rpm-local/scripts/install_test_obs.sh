#!/bin/sh -ex
REPO_FILE="home:osmith42.repo"

# Download repo file
cd /root/yum_repos
if ! [ -e "$REPO_FILE" ]; then
	dnf --setopt=keepcache=1 -y install wget
	wget https://download.opensuse.org/repositories/home:osmith42/CentOS_8_Stream/home:osmith42.repo
fi

# Enable repo
cp "/root/yum_repos/$REPO_FILE" "/etc/yum.repos.d/$REPO_FILE"

# update index
dnf --setopt=keepcache=1 -y check-update /etc/yum.repos.d/$REPO_FILE

# install packages
# somehow -y is not enough
yes | dnf --setopt=keepcache=1 -y install osmo-trx-uhd
