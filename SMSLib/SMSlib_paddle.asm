;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_paddle
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_detectPaddle
	.globl _SMS_readPaddle
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
;SMSlib_paddle.c:20: _Bool SMS_detectPaddle (unsigned char port) __z88dk_fastcall __naked {
;	---------------------------------
; Function SMS_detectPaddle
; ---------------------------------
_SMS_detectPaddle::
;SMSlib_paddle.c:55: __endasm;
	ld	a,l
	or	a
	ld	bc,#0
	jr	nz, detect_second_pad
	read:
	in	a,(#0xDC)
	and	#0x20
	jr	nz, skip_inc
	inc	c
	skip_inc:
	djnz	read
	jr	discriminate
	detect_second_pad:
	in	a,(#0xDD)
	and	#08
	jr	nz, skip_inc_2
	inc	c
	skip_inc_2:
	djnz	detect_second_pad
	discriminate:
	ld	a,c
	ld	l,#0 ; set false
	sub	#0x60
	ret	c
	cp	#(0xA0 -0x60)
	ret	nc
	inc	l ; set true
	ret
;SMSlib_paddle.c:56: }
;SMSlib_paddle.c:58: unsigned char SMS_readPaddle (unsigned char port) __z88dk_fastcall __naked {
;	---------------------------------
; Function SMS_readPaddle
; ---------------------------------
_SMS_readPaddle::
;SMSlib_paddle.c:151: __endasm;
	ld	a,l
	or	a
	jr	nz, read_second_pad
;	First, synchronize by waiting until port A key 2 is high.
;
;	Without this, the values occasionally glitches on real hardware,
;	because the bits may be in the middle of changing and are therefore
;	not reliable. (Remember the real world is analog)
;
	wait_5_set_sync:
	in	a,(#0xDC)
	bit	5,a
	jr	z, wait_5_set_sync ; wait until bit 5 is 1
	wait_5_reset:
	in	a,(#0xDC)
	bit	5,a
	jr	nz, wait_5_reset ; wait until bit 5 is 0
	and	#0x0F
	ld	l,a ; save lower 4 bits into l
	wait_5_set:
	in	a,(#0xDC)
	bit	5,a
	jr	z, wait_5_set ; wait until bit 5 is 1
	and	#0x0F ; save lower 4 bits
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	or	l ; move to high nibble
	ld	l,a ; together with lower part
	ret
	read_second_pad:
	ld	c,#0xDC
;	First, synchronize by waiting until port B key 2 is high.
;
;	Without this, the values occasionally glitches on real hardware,
;	because the bits may be in the middle of changing and are therefore
;	not reliable. (Remember the real world is analog)
	wait_3_set_sync:
	in	a,(#0xDD)
	bit	3,a
	jr	z, wait_3_set_sync ; wait until bit 3 is 1
	wait_3_reset:
	in	a,(#0xDD) ; ensure we are reading both ports same moment
	ld	e,a
	in	b,(c)
	in	a,(#0xDD)
	or	e
	bit	3,a
	jr	nz, wait_3_reset ; wait until bit 5 is 0
	ld	a,b
	and	#0xC0 ; save upper 2 bits
	rlca
	rlca
	ld	l,a ; into l (bits 0,1)
	ld	a,e
	and	#0x03 ; save lower 2 bits
	rlca
	rlca
	or	l ; together with l
	ld	l,a ; into l (bits 2,3)
	wait_3_set:
	in	a,(#0xDD) ; ensure we are reading both ports same moment
	ld	e,a
	in	b,(c)
	in	a,(#0xDD)
	and	e
	bit	3,a
	jr	z, wait_3_set ; wait until bit 5 is 1
	ld	a,b
	and	#0xC0 ; save upper 2 bits
	rrca
	rrca
	ld	h,a ; into h (bits 4,5)
	ld	a,e
	and	#0x03 ; save lower 2 bits
	rrca
	rrca
	or	h ; together with h (bits 6,7)
	or	l ; together with lower part
	ld	l,a
	ret
;SMSlib_paddle.c:152: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
