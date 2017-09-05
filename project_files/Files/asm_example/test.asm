addi r1, r1,#100
addi r5, r5,#4
subi r6,r6,#223
addi r7,r7,#16
ciclo:
subi r1,r1,#20
addi r3,r3,#4
nop
nop
nop
bnez r1,ciclo
nop
nop
addi r20,r0,#5
addi r9,r9,#5
addi r10,r10,#4
addi r3,r3,#4
jal end 
nop
nop
nop
addi r2,r2,#40
end:
add r1,r1,r3
nop
nop
nop
