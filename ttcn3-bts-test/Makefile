
include ../make/Makefile

CFG_SRC_FILES = \
	osmo-bts.src.cfg \
	osmo-bsc.src.cfg

CFG_GEN_FILES = \
	generic/osmo-bts.gen.cfg \
	generic/osmo-bsc.gen.cfg \
	virtphy/osmo-bts.gen.cfg \
	oml/osmo-bts.gen.cfg \
	fh/osmo-bsc.gen.cfg

.PHONY: cfg
cfg: $(CFG_SRC_FILES) $(CFG_GEN_FILES)

# Ensure that we always fetch up-to-date configuration files.
# See https://www.gnu.org/software/make/manual/make.html#Force-Targets
%src.cfg: FORCE_FETCH
	$(MAKE) run \
		RUN_ARGS="-v $(CURDIR):/data --user $(UID)" \
		RUN_CMD="cp /osmo-ttcn3-hacks/bts/$(@:%.src.cfg=%.cfg) /data/$@"
FORCE_FETCH:

generic/osmo-bts.gen.cfg: osmo-bts.src.cfg generic/osmo-bts.confmerge
	osmo-config-merge $^ > $@
	sed -i "s/log gsmtap 127.0.0.1/log gsmtap 172.18.9.10/" $@

generic/osmo-bsc.gen.cfg: osmo-bsc.src.cfg generic/osmo-bsc.confmerge
	osmo-config-merge $^ > $@
	sed -i "s/log gsmtap 127.0.0.1/log gsmtap 172.18.9.10/" $@

virtphy/osmo-bts.gen.cfg: generic/osmo-bts.gen.cfg virtphy/osmo-bts.confmerge
	osmo-config-merge $^ > $@
	sed -i "/osmotrx/d" $@

oml/osmo-bts.gen.cfg: generic/osmo-bts.gen.cfg oml/osmo-bts.confmerge
	osmo-config-merge $^ > $@

fh/osmo-bsc.gen.cfg: generic/osmo-bsc.gen.cfg fh/osmo-bsc.confmerge
	osmo-config-merge $^ > $@

clean:
	@rm -f $(CFG_SRC_FILES) $(CFG_GEN_FILES)
