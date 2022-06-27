#
#   Copyright 2015  Xebia Nederland B.V.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
REGISTRY_HOST?=docker.io
USERNAME?=$(USER)
UID=$(shell id -u)
NAME?=$(shell basename $(CURDIR))
LIBOSMOCORE_BRANCH?=master
OSMO_TTCN3_BRANCH?=master
OSMO_BB_BRANCH?=master
OSMO_BSC_BRANCH?=master
OSMO_BTS_BRANCH?=master
OSMO_CBC_BRANCH?=master
OSMO_GBPROXY_BRANCH?=master
OSMO_GGSN_BRANCH?=master
OSMO_GSM_TESTER_BRANCH?=master
OSMO_HLR_BRANCH?=master
OSMO_HNBGW_BRANCH?=master
OSMO_HNODEB_BRANCH?=master
OSMO_IUH_BRANCH?=master
OSMO_MGW_BRANCH?=master
OSMO_MSC_BRANCH?=master
OSMO_NITB_BRANCH?=master
OSMO_PCU_BRANCH?=master
OSMO_SGSN_BRANCH?=master
OSMO_SIP_BRANCH?=master
OSMO_STP_BRANCH?=master
OSMO_UECUPS_BRANCH?=master
OPEN5GS_BRANCH?=main
BUILD_ARGS?=
RUN_ARGS?=-it
UPSTREAM_DISTRO?=debian:bullseye
DISTRO?=debian-bullseye

# Full OBS repository mirror consists of:
# ${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}
# e.g. "https://downloads.osmocom.org/packages/osmocom:/latest/"
#
# Use if down: OSMOCOM_REPO_MIRROR=http://ftp.uni-stuttgart.de/opensuse
OSMOCOM_REPO_MIRROR?=https://downloads.osmocom.org
OSMOCOM_REPO_PATH?=packages/osmocom:
# Use "nightly" to use the nightly feed
OSMOCOM_REPO_VERSION?=latest
# Build the testsuite with the following mirror. In jenkins we always want to
# point this to http://downloads.osmocom.org, so the same testsuite can be
# used no matter which OSMOCOM_REPO_MIRROR is set. This avoids rebuilding the
# testsuite when we only want to change OSMOCOM_REPO_MIRROR to build different
# subjects under test, and it works even if the OSMOCOM_REPO_MIRROR only has
# a subset of the network:osmocom:latest packages (i.e. no eclipse-titan).
OSMOCOM_REPO_TESTSUITE_MIRROR?=$(OSMOCOM_REPO_MIRROR)

ROOT_DIR=$(shell git rev-parse --show-toplevel)
RELEASE_SUPPORT := $(ROOT_DIR)/make/.make-release-support
IMAGE?=$(REGISTRY_HOST)/$(USER)/$(NAME)

VERSION?=$(shell . $(RELEASE_SUPPORT) ; getRelease)

SHELL=/bin/bash

.PHONY: pre-build docker-build post-build build release patch-release minor-release major-release tag showver \
	push do-push post-push

build: pre-build docker-build post-build

pre-build:
	rm -rf .common
	cp -r $(ROOT_DIR)/common .common


post-build:
	rm -rf .common


post-push:


docker-build: .release
	docker build \
		--build-arg USER=$(USERNAME) \
		--build-arg UID=$(UID) \
		--build-arg REGISTRY=$(REGISTRY_HOST) \
		--build-arg OSMO_TTCN3_BRANCH=$(OSMO_TTCN3_BRANCH) \
		--build-arg UPSTREAM_DISTRO=$(UPSTREAM_DISTRO) \
		--build-arg DISTRO=$(DISTRO) \
		--build-arg OSMOCOM_REPO_MIRROR=$(OSMOCOM_REPO_MIRROR) \
		--build-arg OSMOCOM_REPO_PATH=$(OSMOCOM_REPO_PATH) \
		--build-arg OSMOCOM_REPO_VERSION=$(OSMOCOM_REPO_VERSION) \
		--build-arg OSMOCOM_REPO_TESTSUITE_MIRROR=$(OSMOCOM_REPO_TESTSUITE_MIRROR) \
		--build-arg LIBOSMOCORE_BRANCH=$(LIBOSMOCORE_BRANCH) \
		--build-arg OSMO_BB_BRANCH=$(OSMO_BB_BRANCH) \
		--build-arg OSMO_BSC_BRANCH=$(OSMO_BSC_BRANCH) \
		--build-arg OSMO_BTS_BRANCH=$(OSMO_BTS_BRANCH) \
		--build-arg OSMO_CBC_BRANCH=$(OSMO_CBC_BRANCH) \
		--build-arg OSMO_GBPROXY_BRANCH=$(OSMO_GBPROXY_BRANCH) \
		--build-arg OSMO_GGSN_BRANCH=$(OSMO_GGSN_BRANCH) \
		--build-arg OSMO_GSM_TESTER_BRANCH=$(OSMO_GSM_TESTER_BRANCH) \
		--build-arg OSMO_HLR_BRANCH=$(OSMO_HLR_BRANCH) \
		--build-arg OSMO_HNBGW_BRANCH=$(OSMO_HNBGW_BRANCH) \
		--build-arg OSMO_HNODEB_BRANCH=$(OSMO_HNODEB_BRANCH) \
		--build-arg OSMO_IUH_BRANCH=$(OSMO_IUH_BRANCH) \
		--build-arg OSMO_MGW_BRANCH=$(OSMO_MGW_BRANCH) \
		--build-arg OSMO_MSC_BRANCH=$(OSMO_MSC_BRANCH) \
		--build-arg OSMO_NITB_BRANCH=$(OSMO_NITB_BRANCH) \
		--build-arg OSMO_PCU_BRANCH=$(OSMO_PCU_BRANCH) \
		--build-arg OSMO_SGSN_BRANCH=$(OSMO_SGSN_BRANCH) \
		--build-arg OSMO_SIP_BRANCH=$(OSMO_SIP_BRANCH) \
		--build-arg OSMO_STP_BRANCH=$(OSMO_STP_BRANCH) \
		--build-arg OSMO_UECUPS_BRANCH=$(OSMO_UECUPS_BRANCH) \
		--build-arg OPEN5GS_BRANCH=$(OPEN5GS_BRANCH) \
		$(BUILD_ARGS) -t $(IMAGE):latest .
	@DOCKER_MAJOR=$(shell docker -v | sed -e 's/.*version //' -e 's/,.*//' | cut -d\. -f1) ; \
	DOCKER_MINOR=$(shell docker -v | sed -e 's/.*version //' -e 's/,.*//' | cut -d\. -f2) ; \

tag: docker-build
	if [ $$DOCKER_MAJOR -eq 1 ] && [ $$DOCKER_MINOR -lt 10 ] ; then \
		echo docker tag -f $(IMAGE):latest $(IMAGE):$(VERSION) ;\
		docker tag -f $(IMAGE):latest $(IMAGE):$(VERSION) ;\
	else \
		echo docker tag $(IMAGE):latest $(IMAGE):$(VERSION) ;\
		docker tag $(IMAGE):latest $(IMAGE):$(VERSION) ; \
	fi

.release:
	@echo "release=0.0.0" > .release
	@echo INFO: .release created
	@cat .release


release: build push


push: do-push post-push

do-push:
	docker push $(IMAGE):latest
	[ -f .release ] && docker push $(IMAGE):$(VERSION)

snapshot: build push

showver: .release
	@. $(RELEASE_SUPPORT); getVersion

tag-patch-release: VERSION := $(shell . $(RELEASE_SUPPORT); nextPatchLevel)
tag-patch-release: .release tag

tag-minor-release: VERSION := $(shell . $(RELEASE_SUPPORT); nextMinorLevel)
tag-minor-release: .release tag

tag-major-release: VERSION := $(shell . $(RELEASE_SUPPORT); nextMajorLevel)
tag-major-release: .release tag

patch-release: tag-patch-release release
	@echo $(VERSION)

minor-release: tag-minor-release release
	@echo $(VERSION)

major-release: tag-major-release release
	@echo $(VERSION)

# Always use --rm, so we don't waste disk space
# https://osmocom.org/projects/osmocom-servers/wiki/Docker_cache_clean_up
run:
	docker run --rm $(RUN_ARGS) $(IMAGE) $(RUN_CMD)
