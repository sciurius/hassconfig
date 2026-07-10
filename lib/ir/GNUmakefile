#! /bin/make -f

HADIR     := /mnt/ha
DST       = ${HADIR}/config/tasmota_ir_ready/ir_database
TCFG      := $(shell mktemp)
CFGS	  := $(basename $(wildcard *.rjson))

# Tools.
RRJSON	  := rrjson
INSTALL   := install -m 0644

default :: publish

# Rules.
${DST}/%.json :: %.rjson
	${RRJSON} --json $< > ${TCFG}
	${INSTALL} ${TCFG} $@
	rm ${TCFG}

publish :: $(addprefix ${DST}/,$(addsuffix .json,${CFGS}))
