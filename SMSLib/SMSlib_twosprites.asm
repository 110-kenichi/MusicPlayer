;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_twosprites
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_addTwoAdjoiningSprites
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_VDPControlPort	=	0x00bf
_VDPStatusPort	=	0x00bf
_VDPDataPort	=	0x00be
_VDPVCounterPort	=	0x007e
_VDPHCounterPort	=	0x007f
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
;SMSlib_twosprites.c:13: void SMS_addTwoAdjoiningSprites (unsigned char x, unsigned char y, unsigned char tile) __naked __preserves_regs(iyh,iyl) {
;	---------------------------------
; Function SMS_addTwoAdjoiningSprites
; ---------------------------------
_SMS_addTwoAdjoiningSprites::
;SMSlib_twosprites.c:65: __endasm;
	ld	a,(#_SpriteNextFree)
	cp	a,#64 -1
	ret	nc ; we do not have 2 sprites left, leave!
	ld	c,a ; save SpriteNextFree value in c
	ld	b,#0x00
	ld	hl,#2
	add	hl,sp
	ld	e,(hl) ; read X
	inc	hl
	ld	a,(hl) ; read Y
	cp	a,#0xd1
	ret	z ; invalid Y, leave!
	inc	hl
	ld	d,(hl) ; read tile number
	ld	hl,#_SpriteTableY
	add	hl,bc
	dec	a
	ld	(hl),a ; write Y (as Y-1)
	inc	hl
	ld	(hl),a ; write Y again for the second sprite (always as Y-1)
	ld	hl,#_SpriteTableXN
	add	hl,bc
	add	hl,bc
	ld	(hl),e ; write X
	inc	hl
	ld	(hl),d ; write tile number
	ld	a,(#_spritesWidth) ; load current sprite width
	add	a,e
	jr	c,_secondSpriteClipped ; if new X is overflowing, do not place second sprite
	inc	hl
	ld	(hl),a ; write X + spritesWidth
	ld	a,(#_spritesTileOffset) ; load current sprite tile offset
	add	a,d
	inc	hl
	ld	(hl),a ; write tile number + spritesTileOffset
	ld	a,c
	add	a,#2
	ld	(#_SpriteNextFree),a ; save SpriteNextFree new value
	ret
	_secondSpriteClipped:
	ld	hl,#_SpriteNextFree ; second sprite has been clipped, so just inc SpriteNextFree
	inc	(hl)
	ret
;SMSlib_twosprites.c:66: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
