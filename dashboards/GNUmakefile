#! /bin/make -f

default : all

PKGS_PL   := $(basename $(shell find * -name '*.pl' -print))
# dashboards.yaml is special.
PKGS_YAML := $(basename $(shell find * -name '*.yaml' -a '!' -name 'dashboards.yaml' -print))
PKGS      := ${PKGS_PL} ${PKGS_YAML}
HADIR     := /mnt/ha
DST       := ${HADIR}/config

test :
	echo ${PKGS_PL}
	echo ${PKGS_YAML}

all : mount $(addprefix ${DST}/dashboards/,$(addsuffix .yaml,${PKGS}))

mount ::
	test -d ${HADIR}/config/.storage || mount ${HADIR}/config

${DST}/dashboards/%.yaml :: %.pl
	perl $< > $(basename $<).yaml \
	&& install --preserve-timestamps --mode=0665 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/dashboards.yaml :: dashboards.yaml
	install --preserve-timestamps --mode=0665 $< $@

${DST}/dashboards/%.yaml :: %.yaml
	install --preserve-timestamps --mode=0665 $< $@
