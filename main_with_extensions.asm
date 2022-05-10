		asect	0xf3
IOReg:	# Main IO address is 0xf3
		asect   0xf2
IOExt:  # Additional IO adress (for extensions) is 0xf2
		asect	0xf0
stack:	# Address we'll put to stack pointer is 0xf0
		asect   0xe0
celCnt: # And amount of busy cells will be stored in address 0xe0
        # It's an optimization for game state checker


		asect 	0x00
table:  dc 0,1,2     # Horizontal lines
		dc 4,5,6
		dc 8,9,10
		dc 0,4,8     # Vertical lines
		dc 1,5,9
		dc 2,6,10
		dc 0,5,10    # Diagonal lines
		dc 8,5,2
# Table will be stored in bytes 0-10 of RAM


defendingTable:  dc 5         # Center cell (minus 4 variants max)
                 dc 0,2,8,10  # Cells at edges (minus 3 variants max)
				 dc 1,4,6,9   # All others (minus 2 variants max)

# Game states:
game: dc 0b00000000
win:  dc 0b01000000
lose: dc 0b10000000
draw: dc 0b11000000


# Symbols:
space:  dc 0
cross:  dc 1
nought: dc 2

# Turns:
nothing    :   dc 0
correctTurn:   dc 1
incorrectTurn: dc 2

init:	
	ldi	 r0, stack
	stsp r0
	
mainLoop:
	do
		jsr readIO      #  cell -> r3
		ld	r3, r1      # *cell -> r1
		
		if 	       
			tst r1
		is	nz
          	# If cell is not empty,
			# write that turn is not correct
			# and wait for new button press

			ldi r1, incorrectTurn
			jsr storeExt

			continue 
		else 
			# Write that turn is correct

			ldi r1, correctTurn
			jsr storeExt
		fi

		
		jsr humanPlays     # Put a cross 
						   # and check if human wins.
						   #    *cell   := cross
						   #       r2   := state

		if
			tst r2         # If game continues, ...
		is  z
			jsr robotPlays # find suitable cell for a nought 
						   # and check if robot wins.
						   #  *freeCell  := nought
						   #         r2  := state
		fi		
	

		tst	r2
	until hs 	# Infinite loop
	
	halt

clean:
	push r3

	ldi r3, 0
	ldi r1, 10
	ldi r0, table
	while 
		dec r1
	stays nz
		ldc r0, r2
		st  r2, r3 
		inc r0	

		shl r2
		shl r2
		
		ldi r3, IOReg
		st r3, r2
		ldi r3, 0				 
	wend
	
	ldi r1, celCnt
	clr r2
	st  r1, r2
	
	pop r3

	rts	


incCells:
	ldi r1, celCnt
	ld  r1, r2

	inc r2
	st  r1, r2
	rts


storeExt:
	ldi r2, IOExt
	ldc r1, r1
	st  r2, r1
	rts
 
readIO:
	do
		ldi r0, IOReg
		ld	r0, r3     # Wait for button press
		
		if 
			ldi r0, 0b01000000
			and r3, r0	
		is nz
			jsr clean		
		fi
		
		tst	r3
	until mi		 # Wait for bit 7 raise
	
	
	ldi r0, 0b00001111
	and r0, r3
	# Cell addr is stored in r3
	rts	



getGameState:
	# Win, if there are three crosses in a row
	# Lose, if there are three noughts in a row
	# Draw, when all the cells are busy
	# ...and two previous statements are false
	
	push r1
	push r3

	ldi r0, table    # table -> r0
	ldi r3, 9

	while 
		dec r3
	stays nz
	    ldc r0, r2
		inc r0
		
		ld  r2, r2
		# r2 stores 1st row content
		
		if
			tst r2
		is  z
			inc r0
			inc r0
			continue
		fi 
		# If 1st is empty, then we can skip other cells
		
		if
			ldc r0, r1
			inc r0
			
			ld  r1, r1
			cmp r1, r2
		is  ne
			clr r2
			inc r0
			continue
		fi 
		# Check 2nd cell for eq
		
		if
			ldc r0, r1
			inc r0
			
			ld  r1, r1
			cmp r1, r2
		is  ne
			clr r2
			continue
		fi 

		# Check 3rd cell for eq

		# If all cells are eq and not empty,
		# ...finish the cycle
	
		break
	wend
	
	
	if 
		tst r2
	is  z, and                # Check for "draw" state
		ldi r1, celCnt
		ld  r1, r1

		ldi r3, 9
		cmp r1, r3
	is  eq
		ldi r2, 3
	fi
	
	pop r3
	pop r1

	rts


	
storeIO:
	# cellAddr should be stored in bits 2-5 of IO data
	# Ours is in r3
	
	# Game state is stored in bits 6-7 of IO data
	# Ours is in r2

	# Symbol ID is stored in bits 0-1 of IO data
	# Ours is in r1

	tst  r3

	shl  r3
	shl  r3
	
	or   r1, r3
	
	ldi  r1, game
	add  r1, r2
	ldc  r2, r2 
	
	or   r2, r3	

	# Now r3 contains updated IO data
	ldi  r0, IOReg
	st   r0, r3
	rts


humanPlays:
	jsr incCells
	# cellAddr is stored in r3

	ldi  r1, cross
	ldc  r1, r1
	  
	st   r3, r1        # cellData := symbol

	jsr  getGameState  # r2 := gameState
	jsr  storeIO

	rts
	

geniusAI:
	ldi r0, defendingTable
	ldi r2, 10

	while 
		dec r2
	stays nz
		ldc r0, r3
		ld  r3, r1
		
		if 
			tst r1
		is	z
			break
		fi
		
		inc r0
	wend
	
	rts
	
	
robotPlays:
	jsr incCells
	jsr geniusAI 	   # free cell -> r3
	
	ldi r1, nought
	ldc r1, r1
	
	st  r3, r1        # *cell := symbol

	jsr getGameState  # r2 := gameState
	jsr storeIO
	
	rts
	
end	