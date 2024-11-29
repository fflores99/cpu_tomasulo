.data
	x: .word
	y: .word
.text

Init:
	addi ra, zero, 1
	addi sp, zero, 2
	addi gp, zero, 3
	addi tp, zero, 4
	
	add sp, sp, ra
	add gp, gp, sp
	add tp, tp, gp
	
	mul sp, gp, tp
	div sp, sp, gp
	
	sw gp, x, t0
	sw sp, y, t0
	
	lw t1, x
	lw t2, y

	beq ra, zero, Init
	bne ra, zero, end
	nop
end:
	jal s1, Init	
	