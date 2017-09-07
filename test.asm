myloop:

addi r1, r0, 4
addi r2, r0, 1840
nop
nop
nop
sw 4(r1), r2       ; should forward
sw 2(r1), r2       ; should forward
nop
nop
nop
lw r3, 4(r1)
lh r4, 4(r1)
lhu r5, 4(r1)
lb r6, 4(r1)
lbu r7, 4(r1)
nop
nop
nop
sb 20(r1), r2       ; should forward
sh 24(r1), r2       ; should forward
nop
nop
nop
addi r4, r3, 15     ; should stall
addi r7, r0, myloop ;move label into r7
nop
nop
nop
jalr r7        	    ;jum
