		asect	0xf3
IOReg:	# Gives the address 0xf3 the symbolic name IOReg
		asect	0xf0
stack:	# Gives the address 0xf0 the symbolic name stack
		
asect 	0x00

init:	
	ldi		r0, stack
	stsp	r0
	
	
main:	
	do
		jsr		readkbd
		 
			
		tst		r3
	until	z
	
	halt
	
 
readkbd:
	ldi		r0, IOReg
	
	do
		ld		r0, r3
		tst		r3
	until	nz
		
	st r0, r3
	
	rts	
	
	
				
end