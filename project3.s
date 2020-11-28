#################################################MIPS_Project3
# Gets a string from user, This string can contain substrings 
# that are separated by a comma. When the input string is passed 
# into a subprogram, a nested program reads each substring.
# Then the substring is converted to base 30. Then the substring 
# base 30 value is converted to decimal. If the substring cannot
# be coverted an invalid message will be stored. The base is 30 
# based on a simple calculation with my id #. A substring in the
# input will be invalid if there are more than 4 characters, has an
# out of range character or is empty after all spaces and tabs are removed.
#
# Arg registers used: $a0, $a1, $a2
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5
# Save registers used: $s0, $s1
# Value registers used: $v0
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
	invalid: .asciiz "NaN\n" # Value that should be printed if the input is invalid

	.text # This is the section where the instructions will be written
	.globl main
main:
	li	$v0, 8		# load value of 8 so syscall knows that it will be reading from and store the input
	la	$a0, x		# Loads the address of the string input to $a0 register
	li	$a1, 1001	# Loads the amount of space that is allocated for the input 
	syscall			# Completes the read string instruction
	
	add	$t7, $zero, $zero
	add	$t8, $zero, $zero
	li	$t4, 1			# Initialize the multiplier for 30^0
	add	$t3, $zero, $zero	# Keeps track of the increments for the whole string loop
	add	$t2, $zero, $zero	# Keeps track of increments for viable characters
	add	$v1, $zero, $zero	# Initializes the decimal representation of the input
	la	$a2, id			# Load the address of my id
	lw	$t5, 0($a2)		# Get the value of the id
	addi	$t6, $zero, 11		# Initialize the number that will be divide the id
	div	$t5, $t6		# X % 11
	mfhi	$t5			# Move the remainder of the division to a register
	addi	$s0, $t5, 26		# N = (X % 11) + 26
	jal	START

	blt	$v1, $zero, PRINVALID	# Checks if the subprogram found the input invalid
	li	$v0, 1			# Loads value that tells syscall to print
	add	$a0, $v1, $zero		# Load the sum from memory so it can be printed
	syscall				# Completes the print instruction
	j	EXIT

PRINVALID:
	li	$v0, 4		# Loads value that tells syscall to print
	la	$a0, invalid	# Load the address of the message so it can be printed
	syscall			# Completes the print instruction

EXIT:
	li	$v0, 10		# Exit program call
	syscall		

START:	
	lb	$t0, 0($a0)		# Load the byte that represents a character from the input string
	li	$t1, 10			# Loads the value of the new line character
	beq	$t0, $t1, ADD	 	# If at the end of the string exit the loop early (new line/enter)
	li	$t1, 9			# Loads the ASCII value of TAB
	beq	$t0, $t1, BETWEEN	# Skips over the conversion if it is TAB
	li	$t1, 32			# Loads the ASCII value of SPACE
	beq	$t0, $t1, BETWEEN	# Skips over the conversion if it is SPACE

CONVERT:
	slti	$t1, $t0, 48		# Evaluates if the ASCII value could be a number or letter
	bne	$t1, $zero, INVALID	# If the value of the character is less than it's not a viable character
	bne,	$t8, $zero, INVALID	# If there is a tab or space in between the character the input is invalid
NUM:
	slti	$t1, $t0, 58		# Checks if the value represents a number
	beq	$t1, $zero, UPPER	# If not check to see if it's an uppercase letter
	addi	$t0, $t0, -48		# Adjusts the value of number to base N
	j	CHECK	

UPPER:
	slti	$t1, $t0, 91		# Checks if the value represents an uppercase letter
	beq	$t1, $zero, LOWER	# If not check to see if it's a lowercase letter
	slti	$t1, $t0, 65		# Checks the lower bound of the upper case 
	bne	$t1, $zero, INVALID	# If out of range it is not a viable character
	addi	$t0, $t0, -55		# Adjusts the value of upper case letter to base N
	j	CHECK

LOWER:
	slti	$t1, $t0, 97		# Checks the lower bound of the lower case 
	bne	$t1, $zero, INVALID	# If out of range it is not a viable character
	addi	$t0, $t0, -87		# Adjusts the value of lower case letter to base N

CHECK:
	slt	$t1, $t0, $s0		# Checks if the converted value is less than the base number
	beq	$t1, $zero, INVALID	# If the value cannot be represented by the base it's not added to the sum
	addi 	$t2, $t2, 1		# Increment the viable character counter by one
	li	$t1, 5			# Load 5 to check if there are more than 4 viable character
	beq	$t2, $t1, INVALID	# If the viable counter is 5 exit the loop because the input is invalid	
	addi	$sp, $sp, -4		# Open the stack by a word
	sw	$t0, 0($sp)		# Store the convert value to the stack
	li	$t7, 1			# Turn the viable character flag "on"
	j	INCREMENT

BETWEEN:
	beq	$t7, $zero, INCREMENT	# If the viable character flag is off ignore the between flag
	li	$t8, 1			# Turn the between tabs and spaces flag "on"
	
	
INCREMENT:
	addi 	$a0, $a0, 1		# Increments the base address to read the next character
	addi	$t3, $t3, 1		# Increments the loop counter by one as well 
	slti 	$t1, $t3, 1000		# Checks to make sure the loop is within the limit
	bne	$t1, $zero, START	# If the loop is less than 1000 it continues

ADD:
	beq	$t2, $zero, INVALID	# If no viable characters were collected in the whole input it is invalid
	lb	$t0, 0($sp)		# Loads the base 30 value from the stack (FILO)
	mult	$t0, $t4		# Multiply the base 30 value by the correct base multiplier
	mflo	$t0			# Load the product to the register
	add	$v1, $v1, $t0		# Adds the value to the sum register
	addi	$sp, $sp, 4		# Pops the value that was just loaded
	addi	$t2, $t2, -1		# Reduces the counter by 1
	mult	$t4, $s0		# Increase the multiplier by a factor of 30
	mflo	$t4			# Load the updated value to the multiplier
	li	$t3, 1			# Load the limit of the loop counter
	slt	$t1, $t2, $t3		# Continues to add values to the sum register for the number of viable characters counted
	beq	$t1, $zero, ADD		# If the counter is greater than 1, continue looping
	j	SUBEXIT

INVALID:
	li	$v1, -1			# Returns the sum as -1 to represent an invalid statement

SUBEXIT:
	jr	$ra			# Exit subprogram
		
	