addi r1,r0,#1
addi r2,r0,#4
loop:
addi r1,r1,#1
add r3,r1,r0
add r4,r2,r0
addi r2,r2,#-1
bnez r2,loop
subi r3,r3,#1
addi r2,r2,#1
beqz r0,first_stage
nop
addi r23,r0,#55
first_stage:
j next_stage
addi r24,r0,#55
next_stage:
addi r4,r0,#184
bnez r4,next_stage2
nop
addi r25,r0,#55
next_stage2:
jal end
nop
j real_end
end:
jalr r31
nop
real_end:
addi r22,r0, #100
