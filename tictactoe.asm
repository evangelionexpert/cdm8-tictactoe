		asect	0xf3
IOAdr:	# Main IO address is 0xf3
		asect   0xf2
IOExt:  # IO address for extensions is 0xf2
		asect	0xf0
stack:	# Address we'll store to stack pointer is 0xf0
		asect   0xe0
celCnt: # Amount of busy cells will be stored in address 0xe0
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
# Table contents will be stored in bytes 0-10 of RAM

defendingTable:  dc 5         # Center cell
                 dc 0,2,10,8  # Cells at corners
				 dc 1,9,6,4   # All others

# Game states:
keep: dc 0b00000000
win:  dc 0b01000000
lose: dc 0b10000000
draw: dc 0b11000000

# Symbols:
cross:  dc 1
nought: dc 2

# Turns:
correctTurn:   dc 1
incorrectTurn: dc 2

init:	
	ldi	 r0, stack
	stsp r0
	
mainLoop:
	jsr readIO          #  cell -> r3
	ld	r3, r1          # *cell -> r1
	
	if 	       
		tst r1
	is	nz
		ldi r1, incorrectTurn
		jsr storeExt    # Write that turn is not correct

		br  mainLoop    # Go to the beginning of main loop
	else
		ldi r1, correctTurn
		jsr storeExt	# Write that turn is correct
	fi

	
	jsr humanPlays      # Put a cross 
						# and check if human wins.
						#     *cell   := cross
						#        r2   := state

	if
		tst r2          # If game continues, ...
	is  z
		jsr robotPlays  # find suitable cell for a nought 
						# and check if robot wins.
						#  *freeCell  := nought
						#         r2  := state
	fi		

	br  mainLoop 	    # Infinite loop
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
		
		ldi r3, IOAdr
		st  r3, r2
		ldi r3, 0				 
	wend
	
	ldi r1, celCnt
	st  r1, r3
	
	pop r3

	rts	


incCelCnt:
	# Load global counter from dedicated address
	ldi r1, celCnt
	ld  r1, r2

	# Increment it
	inc r2

	# And store in the same place
	st  r1, r2
	rts


readIO:
	do
		ldi r0, IOAdr
		ld	r0, r3     # Wait for button press
		
		if 
			ldi r0, 0b01000000
			and r3, r0	
		is nz
			jsr clean		
		fi
		
		tst	r3
	until mi		   # Wait for bit 7 raise
	
	
	ldi r0, 0b00001111
	and r0, r3
	# Cell addr is stored in r3
	rts	


getGameState:
	# Win, if there are three crosses in a row
	# Lose, if there are three noughts in a row
	# Draw, when all the cells are busy
	# ...and two previous statements are false

	if                        # Check for "draw" state
		ldi r0, celCnt
		ld  r0, r0

		ldi r2, 5
		cmp r0, r2			  # If global counter is less than 5
	is  lt                   
		clr r2                # Then we keep playing
		rts
	fi
	

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
		tst r2				  # If we didn't lose or win
	is  z, and                # Check for "draw" state
		ldi r1, celCnt
		ld  r1, r1

		ldi r3, 9
		cmp r1, r3			  # If global counter is equal to 9
	is  eq                   
		ldi r2, 3             # Then the state is "draw"
	fi

	ldi  r1, keep             
	add  r1, r2               # Converting r2 to 
	ldc  r2, r2 			  # one of predefined constants
	
	pop r3
	pop r1

	rts


storeIO:
	# Cell address should be stored in bits 2-5 of IO data
	# Ours is in bits 0-3 of r3
	
	# Game state is stored in bits 6-7 of IO data
	# Ours is in r2

	# Symbol ID is stored in bits 0-1 of IO data
	# Ours is in r1

	tst r3

	shl r3
	shl r3
	
	or  r1, r3
	or  r2, r3	

	# Now r3 contains updated IO data
	ldi r0, IOAdr
	st  r0, r3

	rts


storeExt:
	# r1 contains constant

	ldi r2, IOExt
	ldc r1, r1
	st  r2, r1
	
	rts


humanPlays:
	jsr incCelCnt
	# Cell address is stored in r3

	ldi r1, cross
	ldc r1, r1
	  
	st  r3, r1        # *cell := symbol

	jsr getGameState  # r2 := gameState
	jsr storeIO

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

	# We store address of chosen cell in r3
	
	rts
	
	
robotPlays:
	jsr incCelCnt
	jsr geniusAI 	  # free cell -> r3
	
	ldi r1, nought
	ldc r1, r1
	
	st  r3, r1        # *cell := symbol

	jsr getGameState  # r2 := gameState
	jsr storeIO
	
	rts
	
end	