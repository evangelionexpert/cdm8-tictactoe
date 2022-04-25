		asect	0xf3
IOReg:	# Gives the address 0xf3 the symbolic name IOReg
		asect	0xf0
stack:	# Gives the address 0xf0 the symbolic name stack

		asect 	0x20
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

crossWins:  dc 0b00101010
noughtWins: dc 0b00010101


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
						#   cellData   := cross
						#         r2   := state

		if
			tst r2      # If state is win, lose or draw
		is  nz
			break		# We finish the game
		fi
		

		# jsr robotPlays  # Find suitable cell for a nought 
						# And check if robot wins.
						# not implemented yet.
		
		
		
		
		
		
		
		
		 
		 	
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


getGameState:
	stsp r0
	stsp r1
	stsp r3

	ldi r0, table
	ldi r3, 8

	while 
		dec r3
	stays nz
		ldi r2, 0x00
		ld  r1, r0

		shl r1
		shl r1
		shl r1
		shl r1

		or  r1, r2   # Bits 4-5 of r2 is the 1st cell

		inc r0
		ld  r1, r0

		shl  r1
		shl  r1

		or  r1, r2   # Bits 2-3 of r2 is the 2nd cell

		inc r0
		ld  r1, r0

		or  r1, r2   # Bits 0-1 of r2 is the 3rd cell

		inc r0

		# Win, if there are three crosses in a row
		# Lose, if there are three noughts in a row
		# Draw, when all the cells are busy
		# ...and two previous statements are false

		if
			ldi r1, crossWins
			cmp r1, r2
		is eq
			ldi r2, win
			break
		else
			if
				ldi r1, noughtWins
				cmp r1, r2
			is eq
				ldi r2, lose
				break
			else
				ldi r2, game
			fi
		fi
	wend

	ldsp r3
	ldsp r1
	ldsp r0

	rts
	# Game state is stored in r2
	
	
changeIO:
	# cellAddr is stored in r3
	
	# Game state is stored in bits 6-7 of IO data
	# Ours is in r2

	# Symbol ID is stored in bits 0-1 of IO data
	# Ours is in r1

	shl  r3
	shl  r3

	or   r1, r3
	or   r2, r3

	# Now r3 contains updated IO data
	st   r0, r3
	
	rts
	

humanPlays:
	# cellAddr is stored in r3

	ldi  r1, cross  
	st   r3, r1        # cellData := symbol

	jsr  getGameState  # r2 := gameState
	jsr  changeIO

	rts

end