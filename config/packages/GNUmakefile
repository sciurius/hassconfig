#! /bin/make -f

default : pkgs

PKGS_PL   := $(basename $(wildcard *.pl))
PKGS_YAML := $(basename $(wildcard *.yaml))
PKGS      := ${PKGS_PL} ${PKGS_YAML}
HADIR     := /mnt/ha
DST       := ${HADIR}/config

test :
	echo ${PKGS_PL}
	echo ${PKGS_YAML}

pkgs : $(addprefix ${DST}/packages/,$(addsuffix .yaml,${PKGS}))

${DST}/packages/%.yaml :: %.pl
	perl $< > $(basename $<).yaml \
	&& install --mode=0644 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/packages/%.yaml :: %.yaml
	install --preserve-timestamps --mode=0664 $< $@
