#! /bin/make -f

HADIR     := /mnt/ha
DST       := ${HADIR}/config
CONFIGS   := $(basename $(wildcard *.yaml))

default :: all

test ::
	echo ${CONFIGS}

all :: mount $(addprefix ${DST}/,$(addsuffix .yaml,${CONFIGS})) packages dashboards

mount ::
	test -d ${HADIR}/config/.storage || mount ${HADIR}/config

${DST}/%.yaml :: %.yaml
	install --mode=0644 $< $@

.PHONY: packages dashboards

packages :
	${MAKE} ${MFLAGS} -C packages

dashboards :
	${MAKE} ${MFLAGS} -C dashboards
