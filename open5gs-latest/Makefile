DATA_DIR?=$(shell pwd)
USER_ID?=$(shell id -u)
RUN_ARGS=-v $(DATA_DIR):/data --user $(USER_ID) --network host --rm

include ../make/Makefile
