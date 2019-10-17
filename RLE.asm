# Ihfaz Tajwar
# RLE Compression/Decompresseion

.include	"macros.asm"
.eqv	NL	10	# \n
.eqv	NINE	9	# Value of 9
.eqv	UPPER	57	# ASCII value for 9
.eqv	LOWER	48	# ASCII value for 0

	.data
fName:		.space 50
buffer:		.space 1024
heap:		.word 0		#Holds memory address for dynamic memory
size:		.word 0
compSize:	.word 0

	.text
main:	heap_malloc(heap, 1024)		#Allocating 1024 bytes of dynamic memory on heap
	
	print_str("Enter file name to compress or <Enter> to exit: ")
	get_str(fName,50)		#Takes filename
	print_char(NL)
	
	#Checks if user pressed <Enter>, then ends program
	lb $t0,fName
	beq $t0,NL,end
	
	open_file(fName,0)	#Opens file with read mode
	read_file(buffer)	#Read file input onto buffer
	sw $s6,size		#Stores file size onto memory
	
	#Adds null terminator at the end of buffer so that previous input is not displayed
	la $t0,buffer
	add $s6,$s6,$t0
	sb $zero,($s6)
	
	close_file		#Close file
	
	print_str("Original data:\n")
	print_str2(buffer)
	print_char(NL)
	
	print_str("Compressed data:\n")
	
	la $a0,buffer		#Address of the string
	lw $a1,size		#Original size
	lw $a2,heap		#Address of heap memory
	jal compRLE		#Compression algorithm
	
	lw $t0,heap
	print_str3($t0)		#Print compressed data from heap
	print_char(NL)
	
	print_str("Uncompressed data:\n")
	
	lw $a0,heap
	lw $a1,size
	jal decompRLE		#Decompression algorithm
	
	print_char(NL)
	
	print_str("Original file size: ")
	print_int2(size)
	print_char(NL)
	
	print_str("Compressed file size: ")
	print_int2(compSize)
	print_char(NL)
	
	j main			#Loops back to main
	
end:	done			#End program

compRLE:
	addi $s0,$a1,-1		# $s0 = size - 1
	li $t0,0		# i = 0
	li $s7,0
for:	bge $t0,$a1,ret1	# i < n
	li $t1,1		# count = 1
	
while:	add $t2,$a0,$t0
	lb $s1,($t2)		# string[i]
	addi $t3,$t0,1
	add $t3,$a0,$t3
	lb $s2,($t3)		# string[i+1]
	
	bge $t0,$s0,save	# i < size - 1
	bne $s1,$s2,save	# string[i] == string[i+1]
	addi $t1,$t1,1
	addi $t0,$t0,1
	j while
	
save:	sb $s1,($a2)		# Store string[i]
	addi $s7,$s7,1
	addi $a2,$a2,1		# Next heap location
	bgt $t1,NINE,twoDig	# Two digit count
	
	addi $t1,$t1,48		# ASCII value for the number
	sb $t1,($a2)		# Store count
	
	addi $s7,$s7,1		# Compressed size
	addi $a2,$a2,1		# Next heap location
	addi $t0,$t0,1		# i++
	j for
	
twoDig:	li $t8,10
	div $t1,$t8
	mflo $t4		# First digit
	addi $t4,$t4,48		# ASCII value for the first digit
	sb $t4,($a2)		# Store first digit
	addi $s7,$s7,1		# Compressed size
	
	mfhi $t5		# Second digit
	addi $t5,$t5,48		# ASCII value for the second digit
	addi $a2,$a2,1		# Next heap location
	sb $t5,($a2)		# Store second digit
	
	#addi $s7,$s7,1		# Compressed size
	addi $a2,$a2,1		# Next heap location
	addi $t0,$t0,1		# i++
	
	j for
	
ret1:	sw $s7,compSize		#Save compressed size
	jr $ra	
	
decompRLE:
	li $s0,10
lp:	lb $t0,($a0)		#Load characters from compressed data
	lb $t1,1($a0)
	lb $t2,2($a0)
	
	beqz $a1,ret2		#End if size is 0
	blt $t2,LOWER,one	#Checks if count is two digits
	ble $t2,UPPER,two
	
one:	addi $t1,$t1,-48	#Get int value for count
	print_char2($t0,$t1)	#Print out the char sequence
	sub $a1,$a1,$t1		#Decrease size
	addi $a0,$a0,2		#Next char
	j lp

two:	addi $t1,$t1,-48	
	addi $t2,$t2,-48	#Ones place
	mul $t1,$t1,$s0		#Tens place
	add $t1,$t1,$t2		#Calculate int value for two digit count
	
	print_char2($t0,$t1)	#Print out the char sequence
	sub $a1,$a1,$t1		#Decrease size
	addi $a0,$a0,3		#Next char
	j lp
	
ret2:	jr $ra
	
	
	
