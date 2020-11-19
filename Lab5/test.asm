# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
	add %y, %y, %input
	sll %y, %y, 16
	srl %y, %y, 16
	add %x, %x, %input
	srl %x, %x, 16
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
	add %output, %output, %x
	sll %output, %output, 16
	add %output, %output, %y
.end_macro
main:
	#t0 = in, t1 = out
	#s0 = x, s1 = y
	li $t0, 0x00AA00BB
	getCoordinates($t0 $s0 $s1)
	li $t1, 0x000000BB
	li $t2, 0x000000AA
	formatCoordinates($s2 $t2 $t1)
	

#.include "Lab5.asm"