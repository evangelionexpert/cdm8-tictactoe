asect 0x00

ldi r0, 0b10000001
jsr changePole
ldi r0, 0b11000010
jsr changePole
ldi r0, 0b01000000
jsr changePole
ldi r0, 0b00000000
ldi r1, 0xf3
st r1, r0
halt

changePole:
	ldi r1, 0b11000011
	and r1, r0
	while
		ldi r1, 0b00001100
		xor r0, r1
		ldi r2, 0b00001100
		and r2, r1
	stays nz
		while
			ldi r1, 0b00110000
			xor r0, r1
			ldi r2, 0b00110000
			and r2, r1
		stays nz
			ldi r1, 0xf3
			st r1, r0
			ldi r1, 0b00010000
			add r1, r0
		wend
		ldi r1, 0b00110000
		xor r1, r0
		ldi r1, 0b00000100
		add r1, r0
	wend 
	rts
end