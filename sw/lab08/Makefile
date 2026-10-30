# Builds every Lab 8 program: make (or make clean)
# *_sim variants stop after a fixed amount of work so simulations end.
PROGS := gfx_test bench cube_demo switch_demo cube_demo_sim switch_demo_sim
all clean:
	@for p in $(PROGS); do $(MAKE) --no-print-directory -f Makefile.$$p $@ || exit 1; done
.PHONY: all clean
