;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_zx7
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_decompressZX7
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_ROM_bank_to_be_mapped_on_slot1	=	0xfffe
_ROM_bank_to_be_mapped_on_slot2	=	0xffff
_SRAM_bank_to_be_mapped_on_slot2	=	0xfffc
_SMS_SRAM	=	0x8000
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;SMSlib_zx7.c:10: void SMS_decompressZX7 (const void *src, void *dst) __naked {
;	---------------------------------
; Function SMS_decompressZX7
; ---------------------------------
_SMS_decompressZX7::
;SMSlib_zx7.c:91: __endasm;
	pop	bc
	pop	hl ; move *src from stack into hl
	pop	de ; move *dst from stack into de
	push	de
	push	hl
	push	bc
	ld	a, #0x80
	dzx7t_copy_byte_loop:
	ldi	; copy literal byte
	dzx7t_main_loop:
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	jr	nc, dzx7t_copy_byte_loop ; next bit indicates either literal or sequence
;	determine number of bits used for length (Elias gamma coding)
	push	de
	ld	bc, #1
	ld	d, b
	dzx7t_len_size_loop:
	inc	d
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	jr	nc, dzx7t_len_size_loop
	jp	dzx7t_len_value_start
;	determine length
	dzx7t_len_value_loop:
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	rl	c
	rl	b
	jr	c, dzx7t_exit ; check end marker
	dzx7t_len_value_start:
	dec	d
	jr	nz, dzx7t_len_value_loop
	inc	bc ; adjust length
;	determine offset
	ld	e, (hl) ; load offset flag (1 bit) + offset value (7 bits)
	inc	hl
	.db	0xcb, 0x33 ; opcode for undocumented instruction "SLL E" aka "SLS E"
	jr	nc, dzx7t_offset_end ; if offset flag is set, load 4 extra bits
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	rl	d ; insert first bit into D
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	rl	d ; insert second bit into D
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	rl	d ; insert third bit into D
	add	a, a ; check next bit
	call	z, dzx7t_load_bits ; no more bits left?
	ccf
	jr	c, dzx7t_offset_end
	inc	d ; equivalent to adding 128 to DE
	dzx7t_offset_end:
	rr	e ; insert inverted fourth bit into E
;	copy previous sequence
	ex	(sp), hl ; store source, restore destination
	push	hl ; store destination
	sbc	hl, de ; HL = destination - offset - 1
	pop	de ; DE = destination
	ldir
	dzx7t_exit:
	pop	hl ; restore source address (compressed data)
	jp	nc, dzx7t_main_loop
	dzx7t_load_bits:
	ld	a, (hl) ; load another group of 8 bits
	inc	hl
	rla
	ret
;SMSlib_zx7.c:92: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
