.POSIX:
.SUFFIXES:

LIBS=-lfreetype
VARS=LD_LIBRARY_PATH=/usr/lib:${LD_LIBRARY_PATH}

demo:
	mkdir -p bin
	$(VARS) hare build $(LIBS) -o bin/demo .

run:
	$(VARS) hare run $(LIBS) .

.PHONY: demo run
