.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	addi $sp, $sp, -28
	sw	$fp, 28($sp)	
	sw   	$ra, 24($sp)
	sw 	$a0, 20($sp)
	sw 	$a1, 16($sp)
	addi 	$fp, $sp, 28
	beq  $a2,'+',addition
	beq  $a2,'-',subtraction
	beq  $a2,'*',multiplication
	beq  $a2,'/',division
addition:
	addu $v0, $a0,$a1
	j return
subtraction:
	subu $v0, $a0,$a1
	j return
multiplication:
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	j return
division:
	div $a0,$a1
	mflo $v0
	mfhi $v1
	j return
return:
	lw	$fp, 28($sp)	
	lw   	$ra, 24($sp)
	lw 	$a0, 20($sp)
	lw 	$a1, 16($sp)
	addi 	$fp, $sp, 28
	jr $ra
 
