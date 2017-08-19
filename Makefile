

build:
	make -C debian-jessie-build
	make -C osmo-ggsn-master
	make -C osmo-stp-master
	make -C sctp-test
	make -C sigtran-tests
	make -C m3ua-test
	make -C sua-test
	make -C debian-stretch-titan
	make -C ggsn-test
