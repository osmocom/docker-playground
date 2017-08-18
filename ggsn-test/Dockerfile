FROM	debian-stretch-titan

RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git && \
	mkdir /root/projects && (cd /root/projects && ln -sf / git) && \
	cd osmo-ttcn3-hacks/ggsn_tests && \
	./gen_links.sh && \
	./regen_makefile.sh && \
	make compile && \
	make -j8

CMD	cd osmo-ttcn3-hacks/ggsn_tests && \
	ttcn3_start ./GGSN_Tests ./GGSN_Tests.cfg && ttcn3_logmerge *.log
