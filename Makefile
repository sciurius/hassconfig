#! /bin/make -f

default ::
	@echo No default. Use '"publish"' to publish.

publish ::
	${MAKE} ${MFLAGS} -C src publish
