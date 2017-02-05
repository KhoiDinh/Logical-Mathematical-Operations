.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	addi 	$sp, $sp, -24		#allocates frame space
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)									
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	#choose which operation to perform based on operator in register $a2
	beq	$a2, '+', addition		
	beq	$a2, '-', subtraction		
	beq	$a2, '*', multiplication	
	beq     $a2, '/', division						
	j 	main_return			#goes to ending label when desired operation completed			
	
addition:
	jal 	add_logical			#perform add's logical procedure
	j 	main_return			#goes to ending label

subtraction:
	jal 	sub_logical			#performs subtraction's logical procedure
	j 	main_return			#goes to ending label

multiplication:
	jal 	mul_signed			#perform mulitple's signed logical procedure					
	j	main_return			#goes to ending label
 
division:
	jal 	div_signed			#perform division's signed logical procedure					
	j	main_return			#goes to ending label
	
main_return:					#restores frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
#__________________________________________________________________________________________________________	

add_logical:
	addi 	$sp, $sp, -24			#allocates space
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	 
	or	$a2, $zero,0			#carry in bit set to 0 since operation is +
	jal 	add_sub_logical			#goes to label which will determine whether extra step is to be performed
		
	j main_return
#___________________________________________________________________________________________________	
sub_logical:
	addi 	$sp, $sp, -24			#allocate space
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	
	li	$a2,0xFFFFFFFF			#carry in bit set to 1 wsince operation is -
	jal 	add_sub_logical			#goes to label which will determine whether extra step is to be performed
	
	j main_return
#_____________________________________________________________________________________________________________________
add_sub_logical:
	addi 	$sp, $sp,-40					#allocates space
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$s0, 32($sp)
	sw	$s1, 28($sp)
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 40
	
	addi 	$t0,$zero, 0					# create iterator value,i, which will be set to 0
	addi	$v0,$zero, 0					# end result to return which is initialized to 0					
	extract_nth_bit($t3, $a2, $zero)			# carry in bit of $a2 in the 0th position  inserted into $t3 register
	beq	$a2, 0xFFFFFFFF, inversion_step			# checks if operator is + and if it is, skip inversion and continue to "addition" process
	j add_sub_repitition

inversion_step:
nor	$a1,$zero $a1						# if subtration, invert bit and place it in same register for subtration process
	
add_sub_repitition:
	beq	$t0, 32, add_sub_return				# when i is equal to 32, exit loop and go to ending label
	extract_nth_bit($t4, $a0, $t0)				# register $t4 contains 1st number's ith extracted bit
	extract_nth_bit($t1, $a1, $t0)				# register $t1 contains 2nd number's ith extracted bit
	
	xor	$s3, $t4, $t1					# Y- register $s3 contains A xor B resulting value		
	xor	$s2, $t3, $s3					# Y- register $s2 contains carry in bit of $t3 xor $s3 resulting value	
	
	and	$s1, $t4, $t1					# register $s1 contains $t4 & $t1 resulting value		
	and	$s0, $t3, $s3					# register $s0 contains carry in bit & ($t4 xor $t1) resulting value			
	or	$t3, $s1, $s0					# carry in bit contains s3 | s4 resulting value			
	
	insert_to_nth_bit($v0, $t0, $s2, $t6) 			#insert $s2 into ith bit of masked result
	addi	$t0, $t0, 1					# increment i
	j	add_sub_repitition				# execute loop again
	
add_sub_return:
	move	$v1, $t3					# move final carry out bit to return address $v1
	
	lw	$fp, 40($sp)					#restore frame
	lw	$ra, 36($sp)
	lw	$s0, 32($sp)
	lw	$s1, 28($sp)
	lw	$s2, 24($sp)
	lw	$s3, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra	
#___________________________________________________________________________________________________________________
	mul_signed:
	addi	$sp, $sp, -28					#allocate space
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$s7, 20($sp)	 
	sw	$s4, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 28

	move	$s7, $a0					#save original $a0 to $s7 for later use
	move	$s4, $a1					#save original $a1 to $a4 for later use
	
	bgt	$a0, 0, positive_negative_a1			#if $a0 is gretaer than 0, go directly to checking $a1
	
a0_conversion:
	jal twos_complement
	
	move	$a1, $s4					#insert $s4 which holds original $a1 because the two's compliment of $a1 is 1
	move	$a0, $v0					#$a0=two's compliment of $v0
			
positive_negative_a1:
	bgt	$a1, 0, multiplication_procedure		#if $a1 is positive, skip preparation_a1 step
	
a1_conversion:
	move	$t2, $a0					#set $t2=$a0 just in case original is modified
	move	$a0, $a1					# set $a0=$a1 for twos_compliment
	jal twos_complement					# $v0 = $a1's two's complement
	move	$a1, $v0					#$a1 = $a1's two's compliment
	move	$a0, $t2					#$a0=twos_compliment of $a0 ($a0 used in other procedures)

multiplication_procedure:
	jal 	mul_unsigned					# pass editted $a0 and $a1 into unsigned multiplication
	li	$t5, 31						# intitialize variable to prepare for insertion
	extract_nth_bit($t2, $s7, $t5)				#extract 31st bit of $a0 		
	extract_nth_bit($t6, $s4, $t5)				#extract 31st bit of $a1
	xor	$t5, $t2, $t6					# if $t2 and $t6 are different, save into $t5 as a negative
	beq	$t5, 0, multiplication_signed_return		# answer is positve, return it
	
xor_not_one:
	move	$a0, $v0					# $a0=$v0 for 64bit conversion
	move	$a1, $v1					# $a1=$v1 for 64bit conversion
	jal 	twos_complement_64bit
	j multiplication_signed_return	
		
multiplication_signed_return:
	lw	$fp, 28($sp)					#restore frame
	lw	$ra, 24($sp)
	lw	$s7, 20($sp)
	lw	$s4, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
#______________________________________________________________________________________________________________

mul_unsigned:
	addi	$sp, $sp, -32					#allocate space
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$s5, 24($sp)
	sw	$s6, 20($sp)
	sw	$a0, 16($sp)  					# M(multiplicand)
	sw	$a1, 12($sp)					# L(multiplier)
	sw	$a3, 8($sp)
	addi	$fp, $sp, 32
	
	addi	$t2,$zero, 0					#initialize i variable to 0
	addi	$s5,$zero, 0					#set product varaible to 0	
	move	$t9, $a0
	move	$t8, $a1
multiplication_unsigned_repitition:
	beq	$t2, 32, multiplication_unsigned_return 	#if loop has been executed 32 time (i==32) exit loop and go to multiple's unisgned return label	
	extract_nth_bit($a3, $t8 ,$zero)			# extract register $a1's 0th bit(which is on $t4) and insert into $a3
	jal 	bit_replicator					#pass $a3 to bit replicator and insert value into $v0
	and	$s6, $v0, $t9					#register $s6 will contain remainder & multiplicand result
	move	$a0, $s5 					#product
	move	$a1, $s6 					#X
	jal	add_logical					# does add_logical procedure for that specific bit (H=H+X)
	move	$s5, $v0					# move from return address to $s5 after addition is done to continue mult_unisgned process	
	srl	$t8, $t8, 1					#shift multiplier right 1 for inserting into MSB from product
	extract_nth_bit($t6, $s5, $zero)			#extract $s5's(product) 0th bit(contained in $t4) and insert into $t6
	li	$t7, 31						# intitialize variable to prepare for insertion
	insert_to_nth_bit($t8, $t7, $t6, $t4)			# insert ($t7)product's 0th bit into ($a1)multiplier's 31st position using masked $t4 version
	srl	$s5, $s5, 1					#right shift 1 time product register to prepare LSB insertion for multiplier
	addi	$t2, $t2, 1					#increment i variable
	j	multiplication_unsigned_repitition
	
multiplication_unsigned_return:
	move	$v1, $s5					#move HI value to return register
	move	$v0, $t8					#move LO value to return register
	
	lw	$fp, 32($sp)					#restore frame
	lw	$ra, 28($sp)
	lw	$s5, 24($sp)
	lw	$s6, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 32
	jr	$ra
#______________________________________________________________________________________________________

div_signed:
	addi	$sp, $sp, -28				#allocate space
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$s7, 20($sp)
	sw	$s4, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 28
	move	$s7, $a0  				
	move	$s4, $a1				
	bgt	$a0, 0, positve_negative_div_a1		
	jal 	twos_complement 			#$a0 = dividend, $a1 rewritten for 1
	move	$a0, $v0				#a0 =dividend's two's complement 
	move	$a1, $s4				#$a1 = $s4 (original $a1)
positve_negative_div_a1:				
	bgt	$a1, 0, division_compare
	move	$t2, $a0				#$t2=$a0(two's compliment possibility)
	move	$a0, $a1				#$a0=$a1 (new arguement)
	jal	twos_complement
	move	$a1, $v0				#$a1= divisor's two's complement
	move	$a0, $t2				#$a0 = $t2 (original or two's compliment)
division_compare:
	jal	div_unsigned				#unsigned division procedure for $a0 and $a1 (twos' complement possibility)__
	li	$t5, 31					#determine quotient's sign
determine_sQ:
	extract_nth_bit($t2, $s7, $t5) 			#gets $a0's 31st bit
	extract_nth_bit($t6, $s4, $t5)			#get $a1's 31st bit
	xor	$t0, $t2, $t6				# $t0 = $t2 and $t6 if different

calculate_sQ:						
	move	$t9, $v0				# $t9 = $v0(original quotient)
	move	$t5, $v1				# $t5 = $v1 (original remainder)
	bne	$t0, 1, determine_sR 			# if S >0, skip to determine R
	move	$a0, $t9				# $a0= $t9(quotient) for next procedure
	jal	twos_complement 			#$v0 = quotient's two's compliment, $v1 = extra carry out
	move	$t9, $v0				# $t9 = $v0(saving quotient)
determine_sR:
	bne	$t2, 1, division_signed_return 		# $t2 = $a0's 31st bit >0, go to return
	move	$a0, $t5				#$a0 = $t5(orginal remainder) for next procedure
	jal	twos_complement				# $v0 = two's compliment remainder, $v1 = extra carry out bit
	move	$t5, $v0				#$t5 = $v0, saving remiander
division_signed_return:
	move	$v0, $t9				# $v0=$t9 to return quotient in LO
	move	$v1, $t5				#$v1 = $t5 to return remainder in HI

	lw	$fp, 28($sp)				#restore frame
	lw	$ra, 24($sp)
	lw	$s7, 20($sp)
	lw	$s4, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
#__________________________________________________________________________________________________________________________
div_unsigned:
	addi	$sp, $sp, -24				#allocate space
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$s5, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 24

	or	$t2,$zero, 0				#initialize iterator variable i as 0
	addi	$s5,$zero, 0				#initialize REMAINDER varaible as 0
	li	$t7, 31					# $t7 = 31 for inserting purposes
	move	$t9, $a0				# $t9=divident for saving purpose
	move	$t8, $a1				# $t8=divisor for saving purpose
division_unsigned_repitition:
	beq	$t2, 32, division_unsigned_return	#if loop has been executed 32 times (i==32) go to division unsigned return label 
	sll	$s5, $s5, 1				#left shift remiander, $s5, by 1, to make space to insert quotuent bit
	extract_nth_bit($t6, $t9, $t7)			# $t6=  $a0's 31st bit extracted
	insert_to_nth_bit($s5, $zero, $t6, $t4)		# $s5's(remainder) 0th bit position with masked $t4 = t7
end_insertion:						
	sll	$t9, $t9, 1				#dividend shift left by 1 due to inserting bit into remainder, 0 is 0th bit
	move	$a0, $s5				# sets arguements up for subtraction procdeure
	jal	sub_logical				# goes to subtrtaction procedure
	blt	$v0, 0, end_increment
	move	$s5, $v0				#$v0 after subtraction >0, remainder = subtraction result
	li	$t6, 1					#t6 = 1, resued register
	insert_to_nth_bit($t9, $zero, $t6, $t4)		#quotient's 1st bit = 1(subtraction success), $t9's 0th position = 1 using $t4 as mask 
end_increment:
	addi	$t2, $t2, 1				#increment i
	j	division_unsigned_repitition
division_unsigned_return:
	move	$v0, $t9				#move QUOTIENT register into return register
	move	$v1, $s5				#move REMAINDER result into return rergister
	
	lw	$fp, 24($sp)				#restore frame
	lw	$ra, 20($sp)
	lw	$s5, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
#_______________________________________________________________________________________________________________
bit_replicator:
	addi	$sp, $sp, -16					#allocate space
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a3, 8($sp)
	addi	$fp, $sp, 16 

	beq	$a3, 0, zero_replicator				# if $a3 is postive, call replicate_zero label
								# else
	addi	$v0, $zero,0xFFFFFFFF				# load negative sign extension
	j	bit_return

zero_replicator:
	li	$v0, 0						#zero replication
	
bit_return:
	lw	$fp, 16($sp)					
	lw	$ra, 12($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
#_______________________________________________________________________________________________________________
twos_complement:
	addi	$sp, $sp, -20			#allocate space
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20 

	not	$a0, $a0			#invert $a0
	li	$a1, 1				#get ready to do $a0= ~$a0 + 1($a1)
	jal	add_logical
				
twos_complement_restore:
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
#_______________________________________________________________________________________________________________
twos_complement_64bit:
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)  			
	sw	$a1, 8($sp)			
	addi	$fp, $sp, 20
	
	not	$a0, $a0				#$a0=~$a0
	not	$a1, $a1				#$a1=~$a1
	move	$t2, $a1				# $t2=$a1 for later use
	or	$a1,$zero, 1				#a1 = 1 for add_logical 
	jal 	add_logical				# mimics 2's compliment for 64bit purpose
	move	$t7, $v0				# $t7=LO
	move	$a0, $v1				# $a0 =$v1 old carry in 
	move	$a1, $t2				# $a1 = ~ $a1
	jal	add_logical				# previous carry in + a1
	move	$v1, $v0				# $v1 = $v0, result = HI
	move	$v0, $t7				#$v0(LO) = $t6
	
twos_complement_64bit_restore:
	lw	$fp, 20($sp)				#restore frame
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
