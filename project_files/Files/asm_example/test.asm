addi r1, r0,#100
nop
nop
nop
ciclo:
subi r1,r1,#20
addi r3,r3,#4
nop
nop
beqz r1,ciclo
nop
nop
nop
addi r3,r3,#4
j end
nop
nop
nop
addi r2,r2,#40
end:
add r1,r1,r3
nop
nop
nop
