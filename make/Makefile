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
NAME?=$(shell basename $(CURDIR))
LIBOSMOCORE_BRANCH?=master
OSMO_TTCN3_BRANCH?=master
OSMO_BB_BRANCH?=master
OSMO_BSC_BRANCH?=master
OSMO_BTS_BRANCH?=master
OSMO_GGSN_BRANCH?=master
OSMO_GSM_TESTER_BRANCH?=master
OSMO_HLR_BRANCH?=master
OSMO_IUH_BRANCH?=master
OSMO_MGW_BRANCH?=master
OSMO_MSC_BRANCH?=master
OSMO_NITB_BRANCH?=master
OSMO_PCU_BRANCH?=master
OSMO_SGSN_BRANCH?=master
OSMO_SIP_BRANCH?=master
OSMO_STP_BRANCH?=master
PULL?=
DISTRO?=debian-stretch

RELEASE_SUPPORT := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/.make-release-support
IMAGE?=$(REGISTRY_HOST)/$(USER)/$(NAME)

VERSION?=$(shell . $(RELEASE_SUPPORT) ; getRelease)

SHELL=/bin/bash

.PHONY: pre-build docker-build post-build build release patch-release minor-release major-release tag showver \
	push do-push post-push

build: pre-build docker-build post-build

pre-build:


post-build:


post-push:


docker-build: .release
	docker build \
		--build-arg USER=$(USERNAME) \
		--build-arg OSMO_TTCN3_BRANCH=$(OSMO_TTCN3_BRANCH) \
		--build-arg DISTRO=$(DISTRO) \
		--build-arg LIBOSMOCORE_BRANCH=$(LIBOSMOCORE_BRANCH) \
		--build-arg OSMO_BB_BRANCH=$(OSMO_BB_BRANCH) \
		--build-arg OSMO_BSC_BRANCH=$(OSMO_BSC_BRANCH) \
		--build-arg OSMO_BTS_BRANCH=$(OSMO_BTS_BRANCH) \
		--build-arg OSMO_GGSN_BRANCH=$(OSMO_GGSN_BRANCH) \
		--build-arg OSMO_GSM_TESTER_BRANCH=$(OSMO_GSM_TESTER_BRANCH) \
		--build-arg OSMO_HLR_BRANCH=$(OSMO_HLR_BRANCH) \
		--build-arg OSMO_IUH_BRANCH=$(OSMO_IUH_BRANCH) \
		--build-arg OSMO_MGW_BRANCH=$(OSMO_MGW_BRANCH) \
		--build-arg OSMO_MSC_BRANCH=$(OSMO_MSC_BRANCH) \
		--build-arg OSMO_NITB_BRANCH=$(OSMO_NITB_BRANCH) \
		--build-arg OSMO_PCU_BRANCH=$(OSMO_PCU_BRANCH) \
		--build-arg OSMO_SGSN_BRANCH=$(OSMO_SGSN_BRANCH) \
		--build-arg OSMO_SIP_BRANCH=$(OSMO_SIP_BRANCH) \
		--build-arg OSMO_STP_BRANCH=$(OSMO_STP_BRANCH) \
		$(PULL) -t $(IMAGE):latest .
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


run:
	docker run $(RUN_ARGS) -it $(IMAGE)
