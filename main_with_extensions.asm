	asect	0xf3
IOReg:	# Gives the address 0xf3 the symbolic name IOReg
		asect	0xf0
stack:	# Gives the address 0xe0 the symbolic name stack

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
cross:  dc 1
nought: dc 2

# Game states:
game: dc 0b00000000
win:  dc 0b01000000
lose: dc 0b10000000
draw: dc 0b11000000


init:	
	ldi	 r0, stack
	stsp r0
	
main:
	do
		jsr readIO      # cellAddr -> r3
		ld	r3, r1      # cellData -> r1
		
		if 	       
			tst r1
		is	nz
          # If cell is not empty

			# Write that turn is not correct
			ldi r1, 0xf2
			ldi r2, 2
			st r1, r2
			continue 
		fi              # ... then do nothing
		# Write that turn is correct
		ldi r1, 0xf2
		ldi r2, 1
		st r1, r2
		
		jsr humanPlays  # Put a cross 
						# and check if human wins.
						#
						#   cellData   := cross
						#         r2   := state

		if
			tst r2      # If state is win, lose or draw
		is  z
			jsr robotPlays		# We may finish the game
		fi
		

		  # Find suitable cell for a nought 
						# And check if robot wins.
						# not implemented yet.
		
		
		
		
		
		
		
		 
		tst	r2
	until hs #Infinite loop
	
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
		inc r0	
		st r2, r3 
		shl r2
		shl r2
		ldi r3, IOReg
		st r3, r2
		ldi r3, 0				 
	wend
	pop r3
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
	until mi		 #Wait for bit 7 raise
		
	
	
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

	ldi r0, table # tableAddr -> r0
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
		# Checking 2nd cell for eq
		
		if
			ldc r0, r1
			inc r0
			
			ld  r1, r1
			cmp r1, r2
		is  ne
			clr r2
			continue
		fi 

		# Checking 3rd cell for eq

		# If all cells are eq and not empty,
		# ...finish the cycle
	
		break
	wend
	
	#Checking state is not win or lose 
	if 
		tst r2
	is z
		#Checking is state draw 
		ldi r3, 10
		ldi r0, table
		ldi r2, 3
		while 
			dec r3
		stays nz
			ldc r0, r1
			inc r0
			ld r1, r1
			if 
				tst r1
			is z
				clr r2
				break
			fi	
		wend
	fi
	
	pop r3
	pop r1

	rts
	
	
changeIO:
	# cellAddr should be stored in bits 2-5 of IO data
	# Ours is in r3
	
	# Game state is stored in bits 6-7 of IO data
	# Ours is in r2

	# Symbol ID is stored in bits 0-1 of IO data
	# Ours is in r1
	tst r3

	shl  r3
	shl  r3
	
	or   r1, r3
	
	ldi r1, game
	add r1, r2
	ldc r2, r2 
	
	or   r2, r3	
	# Now r3 contains updated IO data
	
	ldi  r0, IOReg
	st   r0, r3
	rts
	

humanPlays:
	# cellAddr is stored in r3

	ldi  r1, cross
	ldc  r1, r1
	  
	st   r3, r1        # cellData := symbol

	jsr  getGameState  # r2 := gameState
	jsr  changeIO

	rts
	
geniusAI:
	ldi r0, table # tableAddr -> r0
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
	jsr geniusAI # free cell addr -> r3
	
	ldi  r1, nought
	ldc  r1, r1
	
	st   r3, r1        # cellData := symbol

	jsr  getGameState  # r2 := gameState
	jsr  changeIO
	
	rts
	
end