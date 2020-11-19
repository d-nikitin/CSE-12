#Spring20 Lab5 Template File

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
# push(register r)
#	sp -= 4
#	*sp = r
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
# pop (register r)
#	r = *sp
#	sp += 4
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
# getCoordinates(in, x, y)
#	y = in
#	y sheft left 16
#	y shift right 16
#	x = in
#	x shift right 16
.macro getCoordinates(%input %x %y) 	#tried loading words and half words 
	add %y, $0, %input		#gave up and then decided to play with logical shifts
	sll %y, %y, 16			#and won
	srl %y, %y, 16
	add %x, $0, %input
	srl %x, %x, 16
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
# formatCoordinates (out, x, y)
#	out = x
#	out shift left 16
#	out += y
.macro formatCoordinates(%output %x %y)	#same as above played with logical shifts and won
	add %output, $0, %x
	sll %output, %output, 16
	add %output, %output, %y
.end_macro 

# Macro to find the pixel location using 
# (row  * 128) + column
# then muplti by 4 to get the offset to store the color properly
# then add the orgin address of the bitmap so i can directly store the color to that point
# getPixelAddy (out, row, col)
#	out = row*128
#	out += col
#	out *= 4
#	out += 0xFFFF0000
.macro getPixelAddy (%out %row %col)
	mul %out, %row, 128
	add %out, %out, %col
	mul %out, %out, 4
	addi %out, %out, 0xFFFF0000
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
# clearBitMap(color c)
#	var temp
#	for i = 0; i <= 128; ++i
#		for j = 0; j <= 128, ++j
#			getPixelAddy(temp, row, col)
#			*temp = c
clear_bitmap: nop
	li $t1, 0	# row
	li $t2, 0	# col
	row_loop:
		beq $t1, 128, row_done
		col_loop:
			beq $t2, 128, col_done
			getPixelAddy($t3 $t1 $t2)
			sw $a0, ($t3)
			addi $t2, $t2, 1
			j col_loop  
		col_done:
		li $t2, 0
		addi $t1, $t1, 1
		j row_loop
	row_done:
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
# getCoordinates(var coords, color c)
#	var x, y
#	getCoordinates(coords,x,y)
#	var temp
#	getPixelAddy(temp,x,y) 
#	*temp = c
draw_pixel: nop
	getCoordinates($a0 $t0 $t1) # t0 = x, t1 = y
	getPixelAddy ($t2 $t0 $t1)
	sw $a1, ($t2)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
# color formatCoordinates(var coords)
#	var x, y
#	getCoordinates(coords,x,y)
#	var temp
#	getPixelAddy(temp,x,y) 
#	color c = *temp
# 	return c
get_pixel: nop
	getCoordinates($a0 $t0 $t1) # t0 = x, t1 = y
	getPixelAddy ($t2 $t0 $t1)
	lw $v0, ($t2)
	jr $ra

#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_solid_circle: nop #t0-2 need to be pushed for draw pixy
	getCoordinates($a0 $t0 $t1) # t0 = xc t1 = yc
	push($ra)
	add $t5, $a1, $t0 #xmax
	add $t6, $a1, $t1 #ymax
	sub $t3, $t0, $a1 #xmin
	sub $t4, $t1, $a1 #ymin
	move $t9, $a1
 	move $a1, $a2
 	move $a2, $t9		#swaps a1 and a2
 	li $t9, 0
	# t3 = i, $t5 = xmax, $t4 = j, $t6 = tmax
	x_loop_solid:
		bgt $t3, $t5, x_loop_solid_done
		y_loop_solid:
			bgt $t4, $t6, y_loop_solid_done
			sub $t7, $t3, $t0		# a arithmatic
			mul $t7, $t7, $t7
			sub $t8, $t4, $t1
			mul $t8, $t8, $t8
			add $t9, $t8, $t7
			mul $t8, $a2, $a2
			blt $t9, $t8, draw_solid # if a < r^2
			solid_back:
			addi $t4, $t4, 1
			j y_loop_solid
		y_loop_solid_done:
		addi $t3, $t3, 1
		sub $t4, $t1, $a2
		j x_loop_solid
	x_loop_solid_done:
	pop($ra)
	jr $ra
	draw_solid:
		formatCoordinates($a0 $t3 $t4)	#format the coords for draw_pixel
		push($t0)		#push registers that will be used in draw dixel
		push($t1)
		jal draw_pixel
		pop($t1)		#pop the registers back
		pop($t0)
		j solid_back
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop # send xc and yc in $a0, x in $a2, y in $a3
		 # t0-2 need to be pushed for draw pixy
	push($ra)
	move $t9, $a1
 	move $a1, $a2
 	move $a2, $t9		#swaps a1 and a2
 	li $t9, 0
 	move $a3, $a2	# y
	li $a2, 0	# x
	mul $t1, $a3, -2
	addi $t1, $t1, 3 # t1 = d
	push($t1)		#push then pop $t1 bc cirlce pixels edits $t1
	jal draw_circle_pixels
	pop($t1)
	while_loop:
		ble $a3, $a2, while_done
		addi $a2, $a2, 1
		bgt $t1, $0, if		#if statment
		mul $t5, $a2, 4		#else arithmatic
		addi $t5, $t5, 6
		add $t1, $t1, $t5
		if_back:
		push($t1)
		jal draw_circle_pixels	#draw pixels
		pop($t1)
		j while_loop
	while_done:
	pop($ra)	 
	jr $ra
	if:
		subi $a3, $a3, 1	#else arithmatic 
		sub $t5, $a2, $a3
		mul $t5, $t5, 4
		addi $t5, $t5, 10
		add $t1, $t1, $t5
		j if_back
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop
	push($ra)
	push($a0)			#pushes the center coordnates to perserve their contents
	getCoordinates($a0 $t8 $t9) # t8 = xc t9 = yc gets coords and stores them in t8 and t9
	add $t1, $t8, $a2		#then does the arithmatic outlined in the psudo code above
	add $t2, $t9, $a3
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	sub $t1, $t8, $a2		#changes as does the psuedo code for the rest of this function
	add $t2, $t9, $a3
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	add $t1, $t8, $a2
	sub $t2, $t9, $a3
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	sub $t1, $t8, $a2
	sub $t2, $t9, $a3
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	add $t1, $t8, $a3
	add $t2, $t9, $a2
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	sub $t1, $t8, $a3
	add $t2, $t9, $a2
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	add $t1, $t8, $a3
	sub $t2, $t9, $a2
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	sub $t1, $t8, $a3
	sub $t2, $t9, $a2
	formatCoordinates($a0 $t1, $t2)
	jal draw_pixel
	pop($a0)		#gets center coordinates contents back
	pop($ra)
	jr $ra
