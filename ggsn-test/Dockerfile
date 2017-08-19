FROM	debian-stretch-titan

RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git && \
	mkdir /root/projects && (cd /root/projects && ln -sf / git) && \
	cd osmo-ttcn3-hacks/ggsn_tests && \
	./gen_links.sh && \
	./regen_makefile.sh && \
	make compile && \
	make -j8

VOLUME	/data

COPY	GGSN_Tests.cfg /data/GGSN_Tests.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/ggsn_tests/GGSN_Tests && \
	ttcn3_logmerge GGSN*.log
