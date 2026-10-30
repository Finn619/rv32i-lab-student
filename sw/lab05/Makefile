# Builds every Lab 5 program: make (or make clean)
PROGS := hello selftest
all clean:
	@for p in $(PROGS); do $(MAKE) --no-print-directory -f Makefile.$$p $@ || exit 1; done
.PHONY: all clean
