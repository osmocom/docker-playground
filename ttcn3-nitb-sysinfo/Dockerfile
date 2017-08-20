FROM	laforge/debian-stretch-titan

RUN	mkdir /root/projects && (cd /root/projects && ln -sf / git)
RUN	git clone git://git.osmocom.org/osmo-ttcn3-hacks.git

ADD	http://git.osmocom.org/osmo-ttcn3-hacks/patch /tmp/commit
RUN	cd osmo-ttcn3-hacks/sysinfo && \
	git pull && \
	./gen_links.sh && \
	./regen_makefile.sh && \
	make compile && \
	make -j8

VOLUME	/data

COPY	Test.cfg /data/Test.cfg

CMD	cd /data && \
	/osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/sysinfo/Test && \
	ttcn3_logmerge Test*.log
