#! /bin/make -f

default : all

PKGS_PL   := $(basename $(shell find * -name '*.pl' -print))
PKGS_YAML := $(basename $(shell find * -name '*.yaml' -print))
PKGS      := ${PKGS_PL} ${PKGS_YAML}
HADIR     := /mnt/ha
DST       := ${HADIR}/config

test :
	echo ${PKGS_PL}
	echo ${PKGS_YAML}

all : $(addprefix ${DST}/dashboards/,$(addsuffix .yaml,${PKGS}))

${DST}/dashboards/%.yaml :: %.pl
	perl $< > $(basename $<).yaml \
	&& install --preserve-timestamps --mode=0665 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/dashboards.yaml :: dashboards.yaml
	install --preserve-timestamps --mode=0665 $< $@

${DST}/dashboards/%.yaml :: %.yaml
	install --preserve-timestamps --mode=0665 $< $@
