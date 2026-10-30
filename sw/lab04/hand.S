# hand.S - Lab 4 hand-assembly exercise.
#
# Encode every instruction below into hand.hex by hand (one 8-digit hex
# word per line, in program order) using the RISC-V specification's
# instruction formats. Labels are byte offsets from the start (address 0).
#
#   addr  instruction
        addi  x5, x0, 10        # 0x00  n = 10
        addi  x6, x0, 0         # 0x04  sum = 0
loop:   add   x6, x6, x5        # 0x08  sum = sum + n
        addi  x5, x5, -1        # 0x0c  n = n - 1
        bne   x5, x0, loop      # 0x10  repeat while n != 0
        lui   x7, 0x10000       # 0x14  x7 = 0x10000000 (start of DMEM)
        sw    x6, 8(x7)         # 0x18  mem[0x10000008] = sum
        lb    x8, 8(x7)         # 0x1c  sign-extended byte
        addi  x9, x0, -1        # 0x20  x9 = 0xffffffff
        sb    x9, 9(x7)         # 0x24  overwrite byte 1 of the word
        lw    x10, 8(x7)        # 0x28
        lhu   x11, 8(x7)        # 0x2c
        lh    x12, 8(x7)        # 0x30
        jal   x1, done          # 0x34  x1 = return address
        addi  x13, x0, 1        # 0x38  skipped by the jump
done:   lui   x14, 0x30000      # 0x3c  x14 = MMIO base
        sw    x0, 0xfc(x14)     # 0x40  SIM_HALT: stop the simulation
spin:   jal   x0, spin          # 0x44  stay here
