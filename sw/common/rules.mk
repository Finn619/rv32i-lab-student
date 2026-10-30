# rules.mk - shared build rules for the lab software (Lab 5).
# A program's Makefile sets PROG and SRCS and includes this file.
#
#   make            -> build/$(PROG).elf, .dis (disassembly), .imem.hex,
#                      .dmem.hex and prog_image_body.vhd
#
# Toolchain: xPack riscv-none-elf-gcc on PATH.

CROSS   ?= riscv-none-elf-
CC      := $(CROSS)gcc
OBJDUMP := $(CROSS)objdump
PYTHON  ?= python3

COMMON  := $(dir $(lastword $(MAKEFILE_LIST)))
TOOLS   := $(COMMON)../../tools
BUILD   ?= build

ARCH    := -march=rv32i_zicsr -mabi=ilp32
CFLAGS  ?= -O2 -g
CFLAGS  += $(ARCH) -ffreestanding -fno-builtin -nostdlib -Wall -Wextra -I$(COMMON)
LDFLAGS += $(ARCH) -nostdlib -nostartfiles -T $(COMMON)link.ld -Wl,--gc-sections \
           -Wl,-Map,$(BUILD)/$(PROG).map
LIBS    := -lgcc

OBJS := $(BUILD)/crt0.o $(BUILD)/lib.o $(patsubst %.c,$(BUILD)/%.o,$(filter %.c,$(SRCS))) \
        $(patsubst %.S,$(BUILD)/%.o,$(filter %.S,$(SRCS)))

all: $(BUILD)/$(PROG).imem.hex $(BUILD)/$(PROG).dis

$(BUILD)/%.o: %.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@
$(BUILD)/%.o: %.S | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@
$(BUILD)/crt0.o: $(COMMON)crt0.S | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@
$(BUILD)/lib.o: $(COMMON)lib.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/$(PROG).elf: $(OBJS) $(COMMON)link.ld
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

$(BUILD)/$(PROG).dis: $(BUILD)/$(PROG).elf
	$(OBJDUMP) -d -M no-aliases,numeric $< > $@

$(BUILD)/$(PROG).imem.hex: $(BUILD)/$(PROG).elf $(TOOLS)/gen_mem.py
	$(PYTHON) $(TOOLS)/gen_mem.py $< --out-dir $(BUILD) --name $(PROG)

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)

.PHONY: all clean
