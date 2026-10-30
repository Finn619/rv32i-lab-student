# RV32I lab - student repository
#
#   make test LAB=1              run Lab 1's tests (GHDL)
#   make test LAB=4 SIM=nvc      same with NVC
#   make test LAB=3 TESTCASE=directed_effects   one cocotb test only
#   make test LAB=4 K=alu        only the pytest cases whose name contains 'alu'
#   make test LAB=1 PYTEST_ARGS=-s   show the simulator output, incl. cocotb's per-test table
#   make test LAB=2 WAVES=1      also dump waveforms (sim_build/<sim>/<top>/)
#   make elab                    check that every design unit analyses and elaborates
#   make sw                      build all software (needs riscv-none-elf-gcc)
#   make arch-test-fetch         download the riscv-arch-test suite (Lab 6)
#   make quartus | make vivado   create the FPGA project (Lab 7; vendor tools on PATH)
#   make clean

SIM      ?= ghdl
LAB      ?=
TESTCASE ?=
K        ?=
PYTEST_ARGS ?=
WAVES    ?= 0
PYTHON   ?= python3

export SIM TESTCASE WAVES

.PHONY: test test-all elab sw arch-test-fetch quartus vivado clean

test:
	@if [ -z "$(LAB)" ]; then echo "usage: make test LAB=<0..8> [SIM=ghdl|nvc] [TESTCASE=name]"; exit 2; fi
	cd tests && $(PYTHON) -m pytest -v -p no:cacheprovider $(PYTEST_ARGS) $(if $(K),-k "$(K)") lab0$(LAB)

test-all:
	cd tests && $(PYTHON) -m pytest -v -p no:cacheprovider

elab:
	@mkdir -p sim_build/elab
	cd sim_build/elab && rm -f *.cf && \
	  ghdl -a --std=08 $(addprefix ../../,$(shell grep -v '^#' rtl/sources.f)) \
	    ../../sim/prog_image_body_sim.vhd ../../sim/clkgen_sim.vhd ../../sim/soc_tb.vhd \
	    ../../sim/core_tb.vhd ../../sim/tb_control.vhd \
	    ../../boards/de10lite/de10lite_top.vhd ../../boards/basys3/basys3_top.vhd \
	    ../../lab0/counter.vhd && \
	  for top in soc_tb core_tb tb_control de10lite_top basys3_top counter; do \
	    ghdl -e --std=08 $$top || exit 1; done && echo "elaboration OK"

sw:
	$(MAKE) -C sw/lab05
	$(MAKE) -C sw/lab07
	$(MAKE) -C sw/lab08

arch-test-fetch:
	$(PYTHON) arch-test/archtest.py fetch

quartus:
	$(MAKE) -C sw/lab07
	quartus_sh -t scripts/quartus/create_project.tcl

vivado:
	$(MAKE) -C sw/lab07
	vivado -mode batch -source scripts/vivado/create_project.tcl

clean:
	rm -rf sim_build build arch-test/build
	-$(MAKE) -C sw/lab05 clean
	-$(MAKE) -C sw/lab07 clean
	-$(MAKE) -C sw/lab08 clean
