addi r1,r0,100
addi r2,r0,-1
sw 16(r0),r2
addi r3,r0,3
sra r5,r2,r3
loop:
sw 4(r0),r1
lw r6,4(r0)
subi r1,r1,20
bnez r1,loop
nop
addi r25,r25,8
addi r24,r24,5
xor r26,r24,r25
mult r26,r24,r25
jalr r26
nop
add r1,r1,r2
nop
andi r2,r1,r2
nop
sgti r30,r25,1
nop
nop
nop
nop
sub r24,r25,r26
nop
lb r29, 16(r0)

