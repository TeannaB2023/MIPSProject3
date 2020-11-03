#################################################MIPS_Project2
# Gets a string from user, reads it, converts the string to base
# 30 then prints out the decimal conversion of the base 30 value.
# The base is 30 based on a simple calculation with my id #. The 
# input will be invalid if there are more than 4 characters, has an
# out of range character or is empty after all spaces and tabs are removed.
#
# Arg registers used: $a0, $a1, $a2, $a3
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5
# Save registers used: $s0, $s1
# Value registers used: $v0, $v1
#
# Pre: none
# Post: $v1 contains the return value
# Returns: the decimal value of a viable string input in base 30
#
# Called by: main
# Calls: Subprogram for conversion

	.data # This is the section to declare variables that will be used in the program
	x: .space 1001 		# The space for the input is initialized (will only read 1000 characters endline)
	id: .word 02924893	# Defines the value of Teanna Barrett's id
	invalid: .asciiz "Invalid input" # Value that should be printed if the input is invalid

	.text # This is the section where the instructions will be written
	.globl main
main:
	li	$v0, 8		# load value of 8 so syscall knows that it will be reading from and store the input
	la	$a0, x		# Loads the address of the string input to $a0 register
	li	$a1, 1001	# Loads the amount of space that is allocated for the input 
	syscall			# Completes the read string instruction
	
	add	$t3, $zero, $zero	# Keeps track of the increments for the whole string loop
	add	$t7, $zero, $zero	# Keeps track of increments for viable characters
	la	$a2, id			# Load the address of my id
	lw	$t5, 0($a2)		# Get the value of the id
	addi	$t6, $zero, 11		# Initialize the number that will be divide the id
	div	$t5, $t6		# X % 11
	mfhi	$t5			# Move the remainder of the division to a register
	addi	$s0, $t5, 26		# N = (X % 11) + 26
	jal	TORS
	
	li	$v0, 1		# Loads value that tells syscall to print
	lb	$a0, 0($a0)	# Load the sum from memory so it can be printed
	syscall			# Completes the print instruction

	li	$v0, 10		# Exit program call
	syscall		

TORS:	
	lb	$t5, 0($a0)		# Load the byte that represents a character from the input string
	li	$t4, 10		
	beq	$t5, $t4, SUBEXIT 	# If at the end of the string exit the loop early
	li	$t4, 9			# Loads the ASCII value of TAB
	beq	$t5, $t4, INCREMENT	# Skips over the conversion if it is TAB
	li	$t4, 32			# Loads the ASCII value of SPACE
	beq	$t5, $t4, INCREMENT	# Skips over the conversion if it is SPACE

CONVERT:
	slti	$t4, $t5, 48		# Evaluates if the ASCII value could be a number or letter
	bne	$t4, $zero, INVALID	# If the value of the character is less than it's not a viable character
NUM:
	slti	$t4, $t5, 58		# Checks if the value represents a number
	beq	$t4, $zero, INCREMENT	# If not check to see if it's an uppercase letter
	addi	$t5, $t5, -48		# Adjusts the value of number to base N	
CHECK:
	addi 	$t7, $t7, 1		# Increment the viable character counter by one

INCREMENT:
	addi 	$a0, $a0, 1		# Increments the base address to read the next character
	addi	$t3, $t3, 1		# Increments the loop counter by one as well 
	slti 	$t4, $t3, 1000		# Checks to make sure the loop is within the limit
	bne	$t4, $zero, TORS	# If the loop is less than 1000 it continues
	j	SUBEXIT

INVALID:
	li	$t7, 0

SUBEXIT:
	sb	$t7, 0($a0)		# Store the viable character counter so it can be printed out (temp)
	jr	$ra			# Exit subprogram
		
	