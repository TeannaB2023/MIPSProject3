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
	invalid: .asciiz "NaN" 	# Value that should be printed if the input is invalid
	comma: .asciiz ","	# Value of comma for the final output

	.text # This is the section where the instructions will be written
	.globl main
main:
	li	$v0, 8		# load value of 8 so syscall knows that it will be reading from and store the input
	la	$a0, x		# Loads the address of the string input to $a0 register
	li	$a1, 1001	# Loads the amount of space that is allocated for the input 
	syscall			# Completes the read string instruction

ID:
	la	$a2, id			# Load the address of my id
	lw	$t5, 0($a2)		# Get the value of the id
	addi	$t6, $zero, 11		# Initialize the number that will be divide the id
	div	$t5, $t6		# X % 11
	mfhi	$t5			# Move the remainder of the division to a register
	addi	$s0, $t5, 26		# N = (X % 11) + 26
	
INIT:
	add	$t7, $zero, $zero	# Initialize flag for viable character collection
	add	$t8, $zero, $zero	# Initialize flag for sandwiched tabs and spaces
	li	$t4, 1			# Initialize the multiplier for 30^2
	add	$t3, $zero, $zero	# Keeps track of the increments for the whole string loop
	add	$t2, $zero, $zero	# Keeps track of increments for viable characters
	add	$v1, $zero, $zero	# Initializes the decimal representation of the input

INTOSTACK:
	lb	$t0, 0($a0)		# Load the byte that represents a character from the input string
	li	$t1, 10			# Load the value of the newline
	beq	$t0, $t1, ALIGN		# If the value is the newline move on to check alignment
	addi	$t3, $t3, 1		# Increment the input string counter
	addi	$sp, $sp, -1		# Move down the stack by one byte
	sb	$t0, 0($sp)		# Store the value of character to the stack
	addi	$a0, $a0, 1		# Increment the memory address for the string
	li	$t1, 1001		# Load the max length of the input string
	blt	$t3, $t1, INTOSTACK	# If the counter is less than the limit continue looping

ALIGN:
	li	$t1, 4			# Load the value of 4 (represents a word)
	div	$t3, $t1		# Divide the length of the string in the stack by 4	
	mfhi	$t1			# Move the remainder to a register
	beq	$t1, $zero, CENTRAL	# If the remainder is 0 move on to central program
	addi	$sp, $sp, -1		# Else Move down the stack
	sb	$zero, 0($sp)		# Store the zero value to the filler 
	addi	$t3, $t3, 1		# Increment the string length by 1
	j	ALIGN			# Check if more filler space needs to be added
	add	$s1, $zero, $t3		# Move the length of the string in the stack to a save register

CENTRAL:
	jal	SUBPROGRAMA		# Calls base 30 conversion program
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$v1, 0($sp)		# Load decimal value from stack
	addi	$sp, $sp, 4
	blt	$v1, $zero, PRINVALID	# Checks if the subprogram found the input invalid
	li	$v0, 1			# Loads value that tells syscall to print
	add	$a0, $v1, $zero		# Load the sum to memory so it can be printed
	syscall				# Completes the print instruction
	j	EXIT

PRINVALID:
	li	$v0, 4		# Loads value that tells syscall to print
	la	$a0, invalid	# Load the address of the message so it can be printed
	syscall			# Completes the print instruction

EXIT:
	li	$v0, 10		# Exit program call
	syscall	

SUBPROGRAMA:	
	add	$t3, $zero, $zero	# Reinitialize the temp register to zero
	jal	SUBPROGRAMB
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	add	$t1, $sp, $s1
	jr	$ra		

SUBPROGRAMB:	
	la	$gp, 0($sp)
	lb	$t0, 0($gp)		# Load the byte that represents a character from the input string
	li	$t1, 44			# Load value of comma to temp register
	beq	$t0, $t1, SETUP		# If the character is a comma 
	beq	$t0, $zero, INCREMENT	# Skip over the filler bytes in stack
	li	$t1, 9			# Loads the ASCII value of TAB
	beq	$t0, $t1, BETWEEN	# Skips over the conversion if it is TAB
	li	$t1, 32			# Loads the ASCII value of SPACE
	beq	$t0, $t1, BETWEEN	# Skips over the conversion if it is SPACE
	jal	SUBPROGRAMC
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

BETWEEN:
	beq	$t7, $zero, INCREMENT	# If the viable character flag is off ignore the between flag
	li	$t8, 1			# Turn the between tabs and spaces flag "on"
	
INCREMENT:
	addi	$t3, $t3, 1		# Increments the loop counter by one as well 
	slt 	$t1, $t3, $s1		# Checks to make sure the loop is within the limit
	beq	$t1, $zero, SETUP	# If the loop is less than string length it continues
	addi 	$gp, $gp, 1		# Increments the base address to read the next character
	j	SUBPROGRAMB

SETUP:	
	beq	$t2, $zero, BINVALID	# If no viable characters were collected in the whole input it is invalid
	addi	$t1, $t2, -1		# Load highest exponent value to temp register
	add	$v1, $zero, $zero	# Reinitialize the value register to 0

MULTIPLIER:
	mult	$t4, $s0		# Multiply base multiplier by 30		
	mflo	$t4			# Update the base 
	addi	$t1, $t1, -1		# Decrement highest exponent
	bge	$t1, $zero, MULTIPLIER	# Keep going until the multiplier for the highest exponent is represented

ADD:
	lw	$t0, 0($sp)		# Loads the base 30 value from the stack (FILO)
	blt	$t0, $zero, BINVALID	# If the viable character value is -1 the whole substring is invalid
	mult	$t0, $t4		# Multiply the base 30 value by the correct base multiplier
	mflo	$t0			# Load the product to the register
	add	$v1, $v1, $t0		# Adds the value to the sum register
	addi	$sp, $sp, 4		# Pops the value that was just loaded
	addi	$t2, $t2, -1		# Reduces the counter by 1
	div	$t4, $s0		# Decrease the multiplier by a factor of 30
	mflo	$t4			# Move the updated value to the multiplier
	li	$t3, 1			# Load the limit of the loop counter
	slt	$t1, $t2, $t3		# Continues to add values to the sum register for the number of viable characters counted
	beq	$t1, $zero, ADD		# If the counter is greater than 1, continue looping
	j	BEXIT

BINVALID:
	addi	$v1, $zero, -1		# Put the invalid value into stack for the substring value

BEXIT:	
	sw	$v1, 0($sp)		# Store decimal value of substring in stack
	jr	$ra			# Exit subprogram B

SUBPROGRAMC:
	slti	$t1, $t0, 48		# Evaluates if the ASCII value could be a number or letter
	bne	$t1, $zero, CINVALID	# If the value of the character is less than it's not a viable character
	bne	$t8, $zero, CINVALID	# If there is a tab or space in between the character the input is invalid
NUM:
	slti	$t1, $t0, 58		# Checks if the value represents a number
	beq	$t1, $zero, UPPER	# If not check to see if it's an uppercase letter
	addi	$t0, $t0, -48		# Adjusts the value of number to base N
	j	CHECK	

UPPER:
	slti	$t1, $t0, 91		# Checks if the value represents an uppercase letter
	beq	$t1, $zero, LOWER	# If not check to see if it's a lowercase letter
	slti	$t1, $t0, 65		# Checks the lower bound of the upper case 
	bne	$t1, $zero, CINVALID	# If out of range it is not a viable character
	addi	$t0, $t0, -55		# Adjusts the value of upper case letter to base N
	j	CHECK

LOWER:
	slti	$t1, $t0, 97		# Checks the lower bound of the lower case 
	bne	$t1, $zero, CINVALID	# If out of range it is not a viable character
	addi	$t0, $t0, -87		# Adjusts the value of lower case letter to base N

CHECK:
	slt	$t1, $t0, $s0		# Checks if the converted value is less than the base number
	beq	$t1, $zero, CINVALID	# If the value cannot be represented by the base it's not added to the sum
	addi 	$t2, $t2, 1		# Increment the viable character counter by one
	li	$t1, 5			# Load 5 to check if there are more than 4 viable characters
	beq	$t2, $t1, CINVALID	# If the viable counter is 5 exit the loop because the input is invalid	
	addi	$sp, $sp, -4		# Open the stack by a word
	sw	$t0, 0($sp)		# Store the convert value to the stack
	li	$t7, 1			# Turn the viable character flag "on"
	j	CEXIT			# Jump to exit subprogram C

CINVALID:
	li	$t1, -1			# Load -1 to represent an invalid character
	addi	$sp, $sp, -4		# Open the stack by a word
	sw	$t1, 0($sp)		# Store the convert value to the stack	
CEXIT:
	jr 	$ra			# Exit subprogram C


		
	