#! /bin/make -f

HADIR     := /mnt/ha
DST       := ${HADIR}/config
CONFIGS   := $(basename $(wildcard *.yaml))
ALL       := $(addprefix ${DST}/,$(addsuffix .yaml,${CONFIGS})) packages dashboards

default :: all

test ::
	echo ${ALL}

all :: mount ${ALL}

mount ::
	test -d ${HADIR}/config/.storage || mount ${HADIR}/config

${DST}/%.yaml :: %.yaml
	install --mode=0644 $< $@

.PHONY: packages dashboards

packages :
	${MAKE} ${MFLAGS} -C packages

dashboards :
	${MAKE} ${MFLAGS} -C dashboards
