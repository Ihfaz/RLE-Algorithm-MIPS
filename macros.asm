#File containing macros

#Ends program
.macro done
	li $v0,10
	syscall
.end_macro

#Prints raw int
.macro print_int (%x)
	add $a0,$zero,%x
	li $v0,1
	syscall
.end_macro

#Prints int from data
.macro print_int2 (%label)
	lw $a0,%label
	li $v0,1
	syscall
.end_macro

#Prints raw char
.macro print_char (%c)
	.data
chr:	.byte %c
	.text
	lb $a0,chr
	li $v0,11
	syscall
.end_macro

#Prints char sequence for decompression algorithm
.macro print_char2 (%char, %count)
	addi $sp,$sp,-4	
	sw $a0,($sp)		#Store the value of $a0 in stack
	
	move $t9,%count
loop:	beqz $t9,exit
	move $a0,%char
	li $v0,11
	syscall
	addi $t9,$t9,-1
	j loop
exit:	lw $a0,($sp)		#Load prev value of $a0 from stack
	addi $sp,$sp,4
.end_macro

#Prints string from literal
.macro print_str (%str)
	.data
txt:	.asciiz %str
	.text
	la $a0,txt
	li $v0,4
	syscall
.end_macro

#Prints string from data
.macro print_str2 (%label)
	.text
	la $a0,%label
	li $v0,4
	syscall
.end_macro

#Prints string from register
.macro print_str3 (%r)
	.text
	move $a0,%r
	li $v0,4
	syscall
.end_macro

#Takes string input from user
.macro get_str (%x, %d)		# %x = input mem address, %d = space
	.text
	la $a0,%x
	li $a1,%d
	li $v0,8
	syscall
.end_macro

#Deletes newline from end of string
.macro del_nl (%s)
	li $s0,10
	la $a0,%s
rep:	lb $s2,($a0)
	beqz $s2,fin
	beq $s2,$s0,fin
	addi $a0,$a0,1
	j rep
fin:	sb $zero,($a0)
.end_macro

#Opens file
.macro open_file (%name, %d)	# %name = filename, %d = read(0)/write(1) mode
	del_nl(%name)
	la $a0,%name
	li $a1,%d
	li $a2,0
	li $v0,13
	syscall
	move $s7,$v0		#File descriptor
	bgtz $v0,nxt
	print_str("Error! File could not be opened.\n")
	done
nxt:
.end_macro

#Reads file
.macro read_file (%buffer)	# %buffer = memory address of file input buffer
	move $a0,$s7
	la $a1,%buffer
	li $a2,1024
	li $v0,14
	syscall
	move $s6,$v0	#File size
.end_macro

#Closes file
.macro close_file
	move $a0,$s7	#File descriptor
	li $v0,16	
	syscall		#Close file
.end_macro

#Allocates dynamic memory
.macro heap_malloc (%mem_address, %space)
	li $a0,%space
	li $v0,9
	syscall
	sw $v0,%mem_address
.end_macro
