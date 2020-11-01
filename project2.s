#################################################MIPS_Project2
# Gets a string from user, reads it, converts the string to base
# 30 then prints out the decimal conversion of the base 30 value.
# The base is 30 based on a simple calculation with my id #. The 
# input will be invalid if there are more than 4 characters, has an
# out of range character or is empty after all spaces and tabs are removed.
#
# Arg registers used: $a0, $a1, $a2, $a3
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5
# Value registers used: $v0, $v1
#
# Pre: none
# Post: $v1 contains the return value
# Returns: the decimal value of a viable string input in base 30
#
# Called by: main
# Calls: Subprogram for conversion

	.data # This is the section to declare variables that will be used in the program
	x: .space 11 		# The space for the input is initialized (will only read 10 characters)
	id: .word 02924893	# Store the value of my personal id

	.text # This is the section where the instructions will be written
main:
	li	$v0, 8	# load value of 8 so syscall knows that it will be reading from and story the input
	la	$a0, x	# Loads the address of the string input to $a0 register
	li	$a1, 11	# Loads the amount of space that is allocated for the input 
	syscall		# Completes the read string instruction
	
	add	$t3, $zero, $zero	# Keeps track of the increments for the loop
	la	$a2, id			# Load the address of my id
	lw	$t5, 0($a2)		# Get the value of the id
	addi	$t6, $zero, 11		# Initialize the number that will be divide the id
	div	$t5, $t6		# X % 11
	mfhi	$t5			# Move the remainder of the division to a register
	addi	$s0, $t5, 26		# N = (X % 11) + 26

START:	
	lb	$t1, 0($a0)		# Loads the ASCII value of the first character
	slti	$t2, $t1, 48		# Evaluates if the ASCII value could be a number or letter
	bne	$t2, $zero, NOT		# If the value of the character is less than it's not a viable number

NUM:
	slti	$t2, $t1, 58		# Checks if the value represents a number
	beq	$t2, $zero, UPPER	# If not check to see if it's an uppercase letter
	addi	$t1, $t1, -48		# Adjusts the value of number to base N
	j ADD				# Add the value to sum

UPPER:
	slti	$t2, $t1, 91		# Checks if the value represents an uppercase letter
	beq	$t2, $zero, LOWER	# If not check to see if it's a lowercase letter
	slti	$t2, $t1, 65		# Checks the lower bound of the upper case 
	bne	$t2, $zero, NOT		# If out of range it is not a viable character
	addi	$t1, $t1, -55		# Adjusts the value of upper case letter to base N
	j ADD				# Add the value to sum

LOWER:
	slti	$t2, $t1, 97		# Checks the lower bound of the lower case 
	bne	$t2, $zero, NOT		# If out of range it is not a viable character
	addi	$t1, $t1, -87		# Adjusts the value of lower case letter to base N
	j ADD				# Add the value to sum

NOT:					
	add	$t1, $zero, $zero	# If not the sum is skipped over

ADD:	
	slt	$t2, $t1, $s0		# Checks if the converted value is less than the base number
	beq	$t2, $zero, INCREMENT	# If the value cannot be represented by the base it's not added to the sum
	add	$t0, $t0, $t1		# Adds the character value to the sum

INCREMENT:
	addi	$a0, $a0, 1		# Increment the address by one
	addi	$t3, $t3, 1		# Increment the loop counter by 1
	slti	$t2, $t3, 10		# This will check if current place of the loop is still on the input 
	bne	$t2, $zero, START	# The program will loop for only 10 iterations
			
	sh	$t0, 0($a0)	# Store the sum in memory right after the id string
	li	$v0, 1		# Loads value that tells syscall to print
	lh	$a0, 0($a0)	# Load the sum from memory so it can be printed
	syscall			# Completes the print instruction

	li	$v0, 10		# Exit program call
	syscall		
