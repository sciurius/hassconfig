#! /bin/make -f

DST       := ../yaml
LIB       := ../lib
ETC	  := ../etc
PLLIB     := ${LIB}/perl5
FFPR	  := -path todo -prune -o
CFGS_PL   := $(basename $(shell find * ${FFPR} -name '*.pl'   -print))
TCFG      := $(shell mktemp)

# Tools.
SECTIONS  := cards
TPOPTS    :=
TTREE     := ttree  -f ${ETC}/ttree.cfg --define sections=${SECTIONS} ${TPOPTS} 
PERL      := perl -Mlib=${PLLIB}
INSTALL   := install -D -m 0644

default :: build publish

# For testing/debugging.
test :
	@echo PL:   ${CFGS_PL}

build :: $(addprefix ${DST}/,$(addsuffix .yaml,${CFGS_PL}))
	${TTREE}

publish :: build
	rsync -rvHOJci --modify-window=2 ${DST}/ /mnt/ha/config/

# Rule for programmatically generated configs.
${DST}/%.yaml :: %.pl
	${PERL} $< > ${TCFG}
	${INSTALL} ${TCFG} $@
	rm ${TCFG}

