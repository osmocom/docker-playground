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
OSMO_TTCN3_BRANCH?=master

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
	docker build --build-arg USER=$(USERNAME) --build-arg OSMO_TTCN3_BRANCH=$(OSMO_TTCN3_BRANCH) \
		-t $(IMAGE):latest .
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
