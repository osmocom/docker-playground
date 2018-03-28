.PHONY: build
build: debian-jessie-build osmo-ggsn-master osmo-stp-master sctp-test sigtran-tests m3ua-test sua-test debian-stretch-titan ttcn3-ggsn-test

.PHONY: ttcn3-bsc-test ttcn3-msc-test ttcn3-bts-test

.PHONY: debian-jessie-build
debian-jessie-build:
	$(MAKE) -C debian-jessie-build

.PHONY: debian-stretch-titan
debian-stretch-titan:
	$(MAKE) -C debian-stretch-titan

.PHONY: osmo-bsc-master
osmo-bsc-master: debian-jessie-build
	$(MAKE) -C osmo-bsc-master

.PHONY: osmo-bts-master
osmo-bts-master: debian-jessie-build
	$(MAKE) -C osmo-bts-master

.PHONY: osmo-msc-master
osmo-msc-master: debian-jessie-build
	$(MAKE) -C osmo-msc-master

.PHONY: osmo-stp-master
osmo-stp-master: debian-jessie-build
	$(MAKE) -C osmo-stp-master

.PHONY: osmocom-bb-trxcon
osmocom-bb-trxcon: debian-jessie-build
	$(MAKE) -C osmocom-bb-trxcon

.PHONY: osmo-ggsn-master
osmo-ggsn-master: debian-jessie-build
	$(MAKE) -C osmo-ggsn-master

.PHONY: ttcn3-bsc-test
ttcn3-bsc-test: debian-stretch-titan osmo-stp-master osmo-bsc-master osmo-bts-master ttcn3-bsc-test
	$(MAKE) -C ttcn3-bsc-test

.PHONY: ttcn3-bts-test
ttcn3-bts-test: debian-stretch-titan osmo-bsc-master osmo-bts-master osmocom-bb-trxcon ttcn3-bts-test
	$(MAKE) -C ttcn3-bts-test

.PHONY: ttcn3-msc-test
ttcn3-msc-test: debian-stretch-titan osmo-stp-master osmo-msc-master ttcn3-msc-test
	$(MAKE) -C ttcn3-msc-test

.PHONY: ttcn3-ggsn-test
ttcn3-ggsn-test: osmo-ggsn-test
	$(MAKE) -C ggsn-test

.PHONY: ttcn3-mgw-test
ttcn3-msc-test: debian-stretch-titan osmo-mgw-master
	$(MAKE) -C ttcn3-mgw-test

.PHONY: sctp-test
sctp-test: debian-jessie-build
	$(MAKE) -C sctp-test

.PHONY: sigtran-tests
sigtran-tests: debian-jessie-build
	$(MAKE) -C sigtran-tests

.PHONY: sua-test
sua-test: osmo-stp-master
	$(MAKE) -C sua-test

.PHONY: m3ua-test
m3ua-test: osmo-stp-master sigtran-tests
	$(MAKE) -C m3ua-test
