 ####################################################################################################
 # Created by:  Nikitin, Dmitriy
 # 		dnikitin
 #		10, May 2020
 # Assignment:	Lab 3: ASCII-risks
 #		CSE 12, Computer Systems and Assembly Language
 # 		UC Santa Cruz, Spring 2020
 # Description: This progam prints a variable sized ASCII diamonds and a sequence of embedded numbers
 # 
 # Notes: 	This program is intended to be run from the MARRS IDE
 ####################################################################################################
 # Pseudo code
 # get user input 
 # iter = 1, num_printed = 1
 # for iter <= in
 #	print newline
 #	iter2= 1
 #	num_ast = (in-iter)*2
 #	for iter2 <= iter
 #		print num_printed
 #		if iter2<iter1 num_printed++
 #	for num_ast != 0
 #		print *
 #		num_ast--
 #	iter2 = 1
 #	temp = num_printed
 #	for iter2 <= iter
 #		print temp
 #		if iter2<iter1 temp--
 #	iter++
 #	num_printed++
 # exit

.text
main:
	loop1:		#get user input and loop if the inpur is 0 or less until we get something 0<
		la $a0, request_num
		jal print_string
		li $v0, 5
		syscall
		bgtz $v0, l1_done
		nop
		la $a0, error_num
		jal print_string
		j loop1
l1_done:
	add $s0, $0, $v0 #store user inpout into register s0
	li $t0, 1	 #set iter to 1 for main loop control
	li $t2, 1	 #set the num to be printed to 1
	loop2:
		la $a0, nl
		jal print_string	#print new line
		li $t3, 1		#set inner loop control (iter2) for number of numbers to be printed from 1 to iter
		sub $t1, $s0, $t0	#set number of asterisks to be printed 
		mul $t1, $t1, 2
		loop_nums1:		#first loop to print numbers until first asterisk ie until iter2 is eqaul to iter
			la $a0, ($t2)
			jal print_num
			beq $t3, $t0 nums1_done
			nop
			addi $t2, $t2, 1	#if we need to print more nums increment nums to be printed
			addi $t3, $t3, 1
			la $a0, tab		#print a tab if we are printing another num
			jal print_string
			j loop_nums1
		nums1_done:
			loop_asc:		#loop to print asteriks prints from (s0-iter) *2 to zero
				beqz $t1, asc_done
				nop
				jal print_ast
				subi $t1, $t1, 1	#decrment ast num
				j loop_asc
		asc_done:
			la $t4, ($t2) 		#copy num to be printed to a temp var
			li $t3, 1 		#set iter2 to 1 for inner loop contorl again
			loop_nums2:
				la $a0, tab		#print tab after num/asterisk
				jal print_string
				la $a0, ($t4)		#print the num to be pritned
				jal print_num		
				beq $t3, $t0, nums2_done		#check if iter2 is eqaul to iter
				nop
				subi $t4, $t4, 1		#if not decrament temp var by 1 for the numbers to count down
				addi $t3, $t3, 1		#incremnt iter2
				j loop_nums2
		nums2_done:
			beq $s0, $t0, done2		#if iter is equal to s0 then exit 
			nop
			addi $t0, $t0, 1		#if not increment number to be printed by 1 and iter by 1 
			addi $t2, $t2, 1		
			j loop2				#loop again
done2:
	j exit_program
	
exit_program:		#exits program
	addi $v0, $0, 10
	syscall
print_ast:		#prints asterisk
	addi $v0, $0, 4
	la $a0, ast
	syscall
	jr $ra
print_num:		#prints an integer
	addi $v0, $0, 1
	syscall
	jr $ra
print_string:		#prints a string
	addi $v0, $0, 4
	syscall
	jr $ra
.data		#strings for newline, tab, requesting user input, if input is invalid and a asterisk with a tab before it
nl:
	.asciiz "\n"
tab:
	.asciiz "\t"
request_num:
	.asciiz "\nEnter the height of the pattern (must be greater than 0):\t"
error_num:
	.asciiz "Invalid Entry!"
ast:
	.asciiz "\t*"
