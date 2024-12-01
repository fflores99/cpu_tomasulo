# BUBBLE SORT & SELECTION SORT
#
# Precondition on Register file
#  Registers set to their register number
#  ex) $0 = 0, $1 = 1, $2 = 2 ... $31 = 31
# Preconditions on Data Memory
#  None. Any data in the first 5 locations will be sorted by Bubble sort.
#  The next 5 data will be sorted by Selection sort.
#
#

.data 
	bubble_arr: .word 48, 97, 57, 87, 57
	sel_arr:    .word 57, 25, 82, 61, 29
.text
#Register preconditions#
	addi x1, x0, 1
	addi x2, x0, 2
	addi x3, x0, 3
	addi x4, x0, 4
	addi x5, x0, 5
	addi x6, x0, 6
	addi x7, x0, 7
	addi x8, x0, 8
	addi x9, x0, 9
	addi x10, x0, 10
	addi x11, x0, 11
	addi x12, x0, 12
	addi x13, x0, 13
	addi x14, x0, 14
	addi x15, x0, 15
	addi x16, x0, 16
	addi x17, x0, 17
	addi x18, x0, 18
	addi x19, x0, 19
	addi x20, x0, 20
	addi x21, x0, 21
	addi x22, x0, 22
	addi x23, x0, 23
	addi x24, x0, 24
	addi x25, x0, 25
	addi x26, x0, 26
	addi x27, x0, 27
	addi x28, x0, 28
	addi x29, x0, 29
	addi x30, x0, 30
	addi x31, x0, 31

	add x0, x0, x0   # nop *** INITIALIZATION FOR BUBBLE SORT ***
	add x31, x4, x0  # x31 = 4
	mul x2, x5, x31  # ak = 4 * num_of_items
	add x0, x0, x0   # nop

BEGIN_1:
	add x3, x0, x0   # ai = 0 *** BUBBLE SORT STARTS ***
	add x4, x3, x31  # aj = ai + 4
	slt x6, x4, x2   # (aj < ak) ?
	beq x6, x0, CHECKER #if no, program finishes. goto checker

LOAD:	
	lw x13, 0(x3)   # mi = M(ai) (LABER: LOAD)
	lw x14, 0(x4)   # mj = M(aj)
	slt x6, x14, x13 # (mj < mi) ?
	beq x6, x0, SKIP_SWAP #if no, skip swap
	
	sw x14, 0(x3) # M(ai) = mj swap
	sw x13, 0(x4) # M(aj) = mi swap
SKIP_SWAP:
	add x3, x3, x31 # aj = aj + 4
	add x4, x4, x31 # aj = aj + 4
	
	slt x6, x4, x2 # (aj < ak) ?
	beq x6, x1, LOAD # if yes, goto LOAD
	sub x2, x2, x31 # ak = ak - 4
	j BEGIN_1
	
CHECKER:
	add x0, x0, x0    # nop *** CHECKER FOR FIRST 5 ITEMS ***
	add x26, x0, x0   # addr1 = 0
	add x27, x26, x31 # addr2 = addr1 + 4
	mul x28, x5, x31  # addr3 = num_of_items * 4
	

	add x28, x28, x26 # addr3 = addr3 + addr1
BEGIN:
	lw x29, 0(x26) # maddr1 = M(addr1)
	lw x30, 0(x27) # maddr2 = M(addr2)
	slt x25, x30, x29 # (maddr2 < maddr1) ?
	
stuck:
	beq x25, x0, continue
	beq x0, x0, stuck	
continue:
	add x26, x26, x31 # addr1 = addr1 + 4
	add x27, x27, x31 # addr2 = addr2 + 4
	
	beq x27, x28, next # if all tested prceed to next program
	beq x0, x0, BEGIN
next:
	nop
	nop
	
SELECTION:
	nop # nop *** INITIALIZATION FOR SELECTION SORT ***
	add x2, x5, x0 # set min = 5
	add x9, x5, x31 # x9 = 9
	add x10, x9, x1 # x10 = 10
	
	add x6, x0, x0 # slt_result = 0
	add x3, x5, x0 # i = 5
loopback2:
	add x4, x3, x1 # j = i + 1 ***Selection Sort starts here***
	mul x13, x3, x31 #ai = i*4
	
	lw x23, 0(x13) #mi = M(ai)
	add x12, x13, x0 # amin = ai
	add x22, x23, x0 # mmin = mi
loopback:
	mul x14, x4, x31 # aj = j*4
	
	lw x24, 0(x14) # mj = M(aj)
	slt x6, x24, x22 # (mj < mmin)
	beq x6, x0, incj #if(no)
	add x12, x14, x0 # amin = aj
	
	
	add x22, x24, x0 # mmin = mj
incj:
	add x4, x4, x1 #j++
	beq x4, x10, jIsTen #(j=10)
	beq x0, x0, loopback#ifno	
	
jIsTen:
	nop
	sw x22, 0(x13) 
	sw x23, 0(x12)
	add x3, x3, x1
	
	add x4, x3, x1
	beq x3, x9, iIsNine
	beq x0, x0, loopback2
iIsNine:
	nop
	
	add x0, x0, x0
	mul x26, x5, x31
	add x27, x26, x31
	mul x26, x5, x31
	
	add x28, x28, x26
next_data2:
	lw x29, 0(x26)
	lw x30, 0(x27)
	slt x25, x29, x30
	
stuck2:
	beq x25, x25, next_data
	beq x0, x0, stuck2
next_data:
	add x26, x26, x31
	add x27, x27, x31
	
	beq x27, x28, next_prog
	beq x0, x0, next_data2
next_prog:
	nop
	nop
