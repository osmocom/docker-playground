DATA_DIR?=$(shell pwd)
USER_ID?=$(shell id -u)
RUN_ARGS=-it -v $(DATA_DIR):/data --user $(USER_ID) --network host

include ../make/Makefile
