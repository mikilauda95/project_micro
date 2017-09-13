addi r1,r0,100
myloop:
add r2,r2,r1
addi r3,r0,10
xori r3,r1,100
subi r1,r1,20
bnez r1,myloop
nop
addi r4,r3,2
addi r21,r0,500
addi r20,r0,4
sw 4(r20), r20
mult r5,r4,r3
sgti r10,r4,4
sll r10,r10,r1
j end
add r3,r3,r3
sra r6,r4,r2
end:
lb r26,4(r20)
lh r27,4(r20)
lhu r28,4(r20)