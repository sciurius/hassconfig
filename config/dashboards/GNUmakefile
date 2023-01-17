#! /bin/make -f

default : all

PKGS_PL   := $(basename $(shell find * -name '*.pl' -print))
PKGS_TT   := $(basename $(shell find * -name '*.tt' -print))
PKGS_YAML := $(basename $(shell find * -name '*.yaml' -print))
PKGS      := ${PKGS_PL} ${PKGS_TT} ${PKGS_YAML}
HADIR     := /mnt/ha
DST       := ${HADIR}/config
TTLIB     := $(shell realpath ../lib/tt)


test :
	echo ${PKGS_PL}
	echo ${PKGS_TT}
	echo ${PKGS_YAML}

all : $(addprefix ${DST}/dashboards/,$(addsuffix .yaml,${PKGS}))

${DST}/dashboards/%.yaml :: %.pl
	perl $< > $(basename $<).yaml \
	&& install --mode=0644 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/dashboards/%.yaml :: %.tt ${TTLIB}/temphum
	tpage --include_path=${TTLIB} $< > $(basename $<).yaml \
	&& install --mode=0644 $(basename $<).yaml $@ \
	&& rm $(basename $<).yaml

${DST}/dashboards/%.yaml :: %.yaml
	install --mode=0644 $< $@
