#! /bin/make -f

default : pkgs

PKGS_PL   := $(basename $(wildcard *.pl))
PKGS_TT   := $(basename $(wildcard *.tt))
PKGS_YAML := $(basename $(wildcard *.yaml))
PKGS      := ${PKGS_PL} ${PKGS_TT} ${PKGS_YAML}
HADIR     := /mnt/ha
DST       := ${HADIR}/config
TTLIB     := $(shell realpath ../lib/tt)

test :
	echo ${PKGS_PL}
	echo ${PKGS_tt}
	echo ${PKGS_YAML}

pkgs : $(addprefix ${DST}/packages/,$(addsuffix .yaml,${PKGS}))

${DST}/packages/%.yaml :: %.pl
	perl $< > $(basename $<).yaml \
	&& install --mode=0644 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/packages/%.yaml :: %.tt ${TTLIB}/temphum
	tpage --include_path=${TTLIB} $< > $(basename $<).yaml \
	&& install --mode=0644 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/packages/%.yaml :: %.yaml
	install --mode=0664 $< $@
