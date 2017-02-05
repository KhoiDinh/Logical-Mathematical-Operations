

#<------------------ MACRO DEFINITIONS ---------------------->#
        # Macro : print_str
        # Usage: print_str(<address of the string>)
        .macro print_str($arg)
	li	$v0, 4     # System call code for print_str  
	la	$a0, $arg   # Address of the string to print
	syscall            # Print the string        
	.end_macro
	
	# Macro : print_int
        # Usage: print_int(<val>)
        .macro print_int($arg)
	li 	$v0, 1     # System call code for print_int
	li	$a0, $arg  # Integer to print
	syscall            # Print the integer
	.end_macro
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
	
	# Macro: read_int
	# Usage: read_int(<reg>)
	.macro read_int($arg)
	li	$v0,5	# Read intger
	syscall
	move	$arg, $v0 # move the data to target reg
	.end_macro
	
	# Macro: print_reg_int
	# Usage: print_reg_int(<reg>)
	.macro print_reg_int ($arg)
	li	$v0, 1		# print_int call
	move	$a0, $arg 	# move the source reg value to $a0
	syscall
	.end_macro
	
	# Macro: lwi
	# Usage: lwi (<reg>, <upper imm>, <lower imm>)
	.macro lwi ($reg, $ui, $li)
	lui $reg, $ui
	ori $reg, $reg, $li
	.end_macro
	
	# Macro: push
	# Usage: push (<reg>)
	.macro push($reg)
	sw	$reg, 0x0($sp)	# M[$sp] = R[reg]
	addi    $sp, $sp, -4	# R[sp] = R[sp] - 4
	.end_macro
	
	# Macro: push
	# Usage: push (<reg>)
	.macro pop($reg)
	addi    $sp, $sp, +4	# R[sp] = R[sp] + 4
	lw	$reg, 0x0($sp)	# M[$sp] = R[reg]
	.end_macro

	.macro push_var_value($varName)
	lw	$t0, $varName
	push($t0)
	.end_macro
	
	.macro push_var_address($varName)
	la	$t0, $varName
	push($t0)
	.end_macro

	.macro call_printf($format)
	la	$a0, $format
	jal	printf
	.end_macro
	
	.macro extract_nth_bit($regD, $regS, $regT)	#$regD=mask, $regS=pattern, $regT=bit pattern
	li	$regD, 1				# load to $regD =1
	sllv  	$regD, $regD, $regT			#  $regD = $regD << $regT
	and 	$regD, $regS, $regD			# $regD = $regS & $regD
	srlv 	$regD, $regD, $regT			# $regD = $regD >> $regT - extracted bit goes to first postion
	.end_macro
		

	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)	#regS=bit position, $regD=result/pattern, $regT = bit to insert
	li	$maskReg, 1					# $maskReg = 1
	sllv  	$maskReg, $maskReg, $regS			# $maskReg = $maskReg << $regS 
	not 	$maskReg, $maskReg				# $maskReg = ~$maskReg
	and 	$regD, $regD, $maskReg				# $regD = $regD & $maskReg
	move	$maskReg, $regT					# $maskReg = $regT 
	sllv 	$maskReg, $maskReg, $regS			# $maskReg = $maskReg << $regS - moved bit before position insertion
	or 	$regD, $regD, $maskReg				# $regD = $regD(result) | mask2 -bit inserted into pattern
	.end_macro
	
