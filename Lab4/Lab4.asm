 ####################################################################################################
 # Created by:  Nikitin, Dmitriy
 # 		dnikitin
 #		20, May 2020
 # Assignment:	Lab 4: ASCII-risks
 #		CSE 12, Computer Systems and Assembly Language
 # 		UC Santa Cruz, Spring 2020
 # Description: This progam read the program arguments converts them from hexidecimal them to 
 #		decimal then sorts then in ascending order
 # 
 # Notes: 	This program is intended to be run from the MARS IDE
 ####################################################################################################
# Psuedo Code
# n = num args
# for i = 0 i<n ++i 
#	print args[i]
# vector<int> nums
# for i = 0 i<n ++i
#	int inc = 1
# 	string s = args[i]
#	int num = 0
#	for j = strlen(s)-1 to 0
# 		int temp = (int)(s[j] -48)
#		if (temp > 9) temp -= 7
#		temp *= inc
#		num += temp
#		inc *=16 
#	nums.push_back(num)
# for each nums
#	print num
# bool swap = true;
#	for(swap)
#		swap = false
#		for i=0 i<n-1 ++i
#			if(nums[i] > nums[i+1])
#				swap nums[i] and nums[i+1]
#				swap = true;
# for each nums
#	print num
# ACTUAL CODE
main:
	add $s0, $a0, $0		#steps up num or args into s0 and the pointer to the array to s1
	add $s1, $a1, $0
	add $t0, $s0, -1
	la $t1, ($s1)			#loads the pointer into a temo
	la $a0, args
	jal print_string
	print_args_loop:		#loops from each arg and prints them to a line seprated by a space
		lw $a0, ($t1)
		jal print_string
		beqz $t0, args_done
		addi $t1, $t1, 4
		subi $t0, $t0, 1
		la $a0, space
		jal print_string
		j print_args_loop
	args_done:
	jal print_newline
	#convert string to decimal
	la $t1, ($s1)
	add $t0, $s0, -1
	addi $s3, $0, 9				#to check for A-F 
	addi $s4, $0, 120			#check for x to terminate loop
	la $s5, array
	convert_todeci:				#iterates from the last char of the string until it hits the x
		lw $t3, ($t1)			#done so i can incrment the power of 16 each iteration
		jal string_length
		addi $t7, $0, 0 		#reset $t7 to 0 to store decimal
		lw $t3, ($t1)
		add $t3, $t3, $t4
		add $t8, $0, 1
		iter_string_loop:
			lb $t5, ($t3)
			beq $t5, $s4, iter_string_done
			subi $t5, $t5, 48
			ble $t5, $s3, is_deci #if $t5 is 9 or less conversion for byte is done if not subtract 7 to get to deci value for A-F
			subi $t5, $t5, 7
			is_deci:
			mul $t5, $t5, $t8		#multiplies the decimal by a power of 16 for conversion
			add $t7, $t7, $t5
			subi $t3, $t3, 1
			mul $t8, $t8, 16		
			j iter_string_loop
		iter_string_done:
		sw $t7, ($s5)			#stores the decimal into the array
		addi $s5, $s5, 4
		beqz $t0 convert_done
		subi $t0, $t0, 1
		addi $t1, $t1, 4		#moves array pointer forward
		j convert_todeci
	convert_done:
	jal print_newline
	la $a0, ints
	jal print_string
	la $s4, array
	add $t0, $s0, -1
	print_ints_loop:		# prints the integers stored int he array
		lw $a0, ($s4)
		li $v0, 1
		syscall
		beqz $t0, print_ints_done
		la $a0, space
		jal print_string
		addi $s4, $s4, 4
		subi $t0, $t0, 1
		j print_ints_loop
	print_ints_done:
	#bubble sort
	addi $t0, $s0, 0
	li $t9, 1		#sets up swap for first iteration
	reset:
	beqz $t9, sort_done		#check if a swap happened through the iterations if it didn't the list is sorted
	li $t9, 0
	li $t1, 1			#t1 controls the loops iteration to stop 1 more the final loop so we dont run off the array
	beq $s0, $t1, sort_done		#for the corner case of there only being 1 argument
	la $t2, array			
	la $t3, array
	addi $t3, $t3, 4		# t2 the first index and t3 is the next one so we can compare them both are iterated by 4
	bubble_sort:
		lw $t4, ($t2)
		lw $t5, ($t3)		#loads the interger values from t2 t t4 and t3 to t5
		blt $t5, $t4, swap
		return:
		addi $t2, $t2, 4
		addi $t3, $t3, 4
		addi $t1, $t1, 1
		beq $t1, $t0, reset	#if we reach the end of the array we need to reset to iterate again or check if we are done
		j bubble_sort
	sort_done:
	jal print_newline
	jal print_newline
	la $a0, sints
	jal print_string
	la $s4, array
	add $t0, $s0, -1
	print_sints_loop:		# prints the intergers in the now sorted array
		lw $a0, ($s4)
		li $v0, 1
		syscall
		beqz $t0, print_sints_done
		la $a0, space
		jal print_string
		addi $s4, $s4, 4
		subi $t0, $t0, 1
		j print_sints_loop
	print_sints_done:
	jal print_newline
	b exit
swap:		#swap array indicies in $t2, $t3 and set $t9 to 1 to indacte swap was done
	li $t9, 1
	sw $t4, ($t3)
	sw $t5, ($t2)
	j return
string_length: #find the lenth of the string in $t3 and stores it in $t4.
	li $t4, 0
	string_loop:
		lb $t5, ($t3)
		beqz $t5, string_done
		addi $t3, $t3, 1
		addi $t4, $t4, 1
		j string_loop
	string_done:
	subi $t4, $t4, 1		#So $t4 will be the last char in the string
	jr $ra
print_string:
	addi $v0, $0, 4
	syscall
	jr $ra
print_newline:
	la $a0, newline
	addi $v0, $0, 4
	syscall
	jr $ra
exit:
	addi $v0, $0, 10
	syscall
.data
array:
	.space 32
space:
	.asciiz " "
newline:
	.asciiz "\n"
args:
	.asciiz "Program arguments:\n"
ints:
	.asciiz "Integer values:\n"
sints:
	.asciiz "Sorted values:\n"
