#! /bin/make -f

HADIR     := /mnt/ha
DST       = ${HADIR}/config
LIB       := ../lib
TTLIB     := ${LIB}/tt
PLLIB     := ${LIB}/perl5
CFGS_PL   := $(basename $(shell find * -name '*.pl'   -print))
CFGS_TT   := $(basename $(shell find * -name '*.tt'   -print))
CFGS_YAML := $(basename $(shell find * -name '*.yaml' -print))
CFGS      := ${CFGS_PL} ${CFGS_TT} ${CFGS_YAML}
TCFG      := $(shell mktemp)

# Tools.
INSTALL   := install -m 0644
TPAGE     := tpage --include_path=${TTLIB} --include_path=${TTLIB}/ui
PERL      := perl -Mlib=${PLLIB}

default ::
	@echo No default. Use '"publish"' to publish.

# For testing/debugging.
test :
	@echo YAML: ${CFGS_YAML}
	@echo PL:   ${CFGS_PL}
	@echo TT:   ${CFGS_TT}

publish :: mount $(addprefix ${DST}/,$(addsuffix .yaml,${CFGS}))

# Make sure the destination is available, mount it if necessary.
mount ::
	test -d ${HADIR}/config/.storage || mount ${HADIR}/config

# Rule for programmatically generated configs.
${DST}/%.yaml :: %.pl
	${PERL} $< > ${TCFG}
	${INSTALL} ${TCFG} $@
	rm ${TCFG}

# Rule for templated config.
# By also depending on the library templates we make sure they
# are rebuilt when a library template changes.
${DST}/%.yaml :: %.tt ${TTLIB}/ui/*
	${TPAGE} $< > ${TCFG}
	${INSTALL} ${TCFG} $@
	rm ${TCFG}

# Rule for straight 'copy publish' config files.
${DST}/%.yaml :: %.yaml
	${INSTALL} $< $@

