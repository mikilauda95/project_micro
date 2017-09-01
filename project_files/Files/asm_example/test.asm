addi r2,r0,#5
nop
nop
nop
add r3,r2,r5
sub r4,r2,r1
sub r5,r1,r2
nop
nop
or r6,r3,r4
slli r3,r3,#2 
addi r1,r2,#5
sle r12,r4,r2
seq r13,r4,r2
sne r14,r4,r2
sge r15,r4,r2
sgt r16,r5,r20
slt r17,r5,r20
nop
nop
nop
sw 21(r0),r3
nop
nop
nop
addi r5,r5,#4
slei r18,r2,#1
sgei r19,r2,#1
seqi r20,r2,#1
snei r21,r2,#1
sgti r22,r2,#1
slti r22,r2,#1
nop
nop
nop
lw r10,21(r0)
nop
nop
nop
subi r2,r2,#4
sub r5,r5,r5
nop
xor r10,r10,r2
sra r5,r5,r2
addi r2,r2,#3
nop
nop
and r3,r3,r1
srli r5,r5,#4
mult r2,r2,r2
nop
beqz 32

