#! /bin/make -f

default ::
	@echo No default. Use '"publish"' to publish.

publish ::
	${MAKE} ${MFLAGS} -C src publish

process ::
	mkdir -p  public/.storage
	${MAKE} ${MFLAGS} DST="${PWD}/public" -C src publish
