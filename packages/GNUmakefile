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

pkgs : mount $(addprefix ${DST}/packages/,$(addsuffix .yaml,${PKGS}))

mount ::
	test -d ${HADIR}/config/.storage || mount ${HADIR}/config


${DST}/packages/%.yaml :: %.pl
	perl $< > $@~ && mv $@~ $@

${DST}/packages/%.yaml :: %.yaml
	cat $< > $@~ && mv $@~ $@
