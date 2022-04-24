		asect	0xf3
IOReg:	# Gives the address 0xf3 the symbolic name IOReg
		asect	0xf0
stack:	# Gives the address 0xf0 the symbolic name stack

		asect 	0x00
table:  dc 0,1,2     # Horizontal lines
		dc 4,5,6
		dc 8,9,10
		dc 0,4,8     # Vertical lines
		dc 1,5,9
		dc 2,6,10
		dc 0,5,10    # Diagonal lines
		dc 8,5,2

# Symbols:
space:  dc 0
nought: dc 1
cross:  dc 2

# Game states:
game: dc 0b00000000
win:  dc 0b01000000
lose: dc 0b10000000
draw: dc 0b11000000


init:	
	ldi	 r0, stack
	stsp r0
	
main:
	ldi r0, IOReg       # r0 is a register for IO Address
	
	do
		jsr readIO      # IO data -> r3
		jsr getCellAddr # cellAddr -> r3
		
		ld	r1, r3      # cellData -> r1
		if 	       
			tst r1
		is	nz          # If cell is not empty
			continue 
		fi              # ... then do nothing
		
		jsr humanPlays  # Put a cross 
						# and check if human wins.
						#
						# IOReg[0-1]   := cross
						# IOReg[2-5]   := cellAddr (r2)
						# IOReg[6-7]   := state
						#   cellData   := cross
						#         r2   := state

		if
			tst r2
		is  z
			break
		fi
		

		# jsr robotPlays  # Find suitable cell for a nought
						# And check if robot wins.
						# 
		
		
		
		
		
		
		
		
		 
		 	
		tst	r1
	until z
	
	halt

	
 
readIO:
	do
		ld	r0, r3     # Wait for button press
		tst	r3
	until nz
	
	# IO data is stored in r3
	rts	
	
	
getCellAddr:
	# Get cell coordinates for the button
	# Cell address is stored in bits 2-5 of IO data (r3)

	ldi  r3, 0b00111100
	and  r2, r3

	shr  r3
	shr  r3

	# Result is stored in r3
	rts
	
	
changeIO:
	# cellAddr is stored in r3
	
	# Game state is stored in bits 6-7 of IO data
	# Ours is in r2

	# Symbol ID is stored in bits 0-1 of IO data
	# Ours is in r1


	st   r3, r1     # cellData := symbol


	shl  r3
	shl  r3

	or   r1, r3
	or   r2, r3

	# Now r3 contains updated IO data

	st   r0, r3     # r0 is IOReg
	
	rts
	

humanPlays:
	# cellAddr is stored in r3

	ldi  r2, game    # game state checker is not yet implemented
	ldi  r1, cross

	jsr changeIO

	rts


end