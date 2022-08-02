;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_spriteAdv
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_reserveSprite
	.globl _SMS_updateSpritePosition
	.globl _SMS_updateSpriteImage
	.globl _SMS_hideSprite
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
;SMSlib_spriteAdv.c:13: signed char SMS_reserveSprite (void) {
;	---------------------------------
; Function SMS_reserveSprite
; ---------------------------------
_SMS_reserveSprite::
;SMSlib_spriteAdv.c:14: if (SpriteNextFree<MAXSPRITES) {
	ld	iy, #_SpriteNextFree
	ld	a, 0 (iy)
	sub	a, #0x40
	jr	NC, 00102$
;SMSlib_spriteAdv.c:15: SpriteTableY[SpriteNextFree]=0xE0;            // so it's offscreen
	ld	bc, #_SpriteTableY+0
	ld	hl, (_SpriteNextFree)
	ld	h, #0x00
	add	hl, bc
	ld	(hl), #0xe0
;SMSlib_spriteAdv.c:16: return(SpriteNextFree++);
	ld	c, 0 (iy)
	inc	0 (iy)
	ld	l, c
	ret
00102$:
;SMSlib_spriteAdv.c:18: return (-1);
	ld	l, #0xff
;SMSlib_spriteAdv.c:19: }
	ret
;SMSlib_spriteAdv.c:21: void SMS_updateSpritePosition (signed char sprite, unsigned char x, unsigned char y) {
;	---------------------------------
; Function SMS_updateSpritePosition
; ---------------------------------
_SMS_updateSpritePosition::
	push	ix
	ld	ix,#0
	add	ix,sp
;SMSlib_spriteAdv.c:23: SpriteTableY[(unsigned char)sprite]=(unsigned char)(y-1);
	ld	e, 4 (ix)
;SMSlib_spriteAdv.c:22: if (y!=0xD1) {                                  // avoid placing sprites at this Y!
	ld	a, 6 (ix)
	sub	a, #0xd1
	jr	Z, 00102$
;SMSlib_spriteAdv.c:23: SpriteTableY[(unsigned char)sprite]=(unsigned char)(y-1);
	ld	bc, #_SpriteTableY+0
	ld	l, e
	ld	h, #0x00
	add	hl, bc
	ld	a, 6 (ix)
	dec	a
	ld	(hl), a
;SMSlib_spriteAdv.c:24: SpriteTableXN[(unsigned char)sprite*2]=x;
	ld	bc, #_SpriteTableXN+0
	ld	h, #0x00
	ld	l, e
	add	hl, hl
	add	hl, bc
	ld	a, 5 (ix)
	ld	(hl), a
	jr	00104$
00102$:
;SMSlib_spriteAdv.c:26: SpriteTableY[(unsigned char)sprite]=0xE0;     // move it offscreen anyway
	ld	hl, #_SpriteTableY+0
	ld	d, #0x00
	add	hl, de
	ld	(hl), #0xe0
00104$:
;SMSlib_spriteAdv.c:28: }
	pop	ix
	ret
;SMSlib_spriteAdv.c:30: void SMS_updateSpriteImage (signed char sprite, unsigned char image) {
;	---------------------------------
; Function SMS_updateSpriteImage
; ---------------------------------
_SMS_updateSpriteImage::
	push	ix
	ld	ix,#0
	add	ix,sp
;SMSlib_spriteAdv.c:31: SpriteTableXN[(unsigned char)sprite*2+1]=image;
	ld	bc, #_SpriteTableXN+0
	ld	l, 4 (ix)
	ld	h, #0x00
	add	hl, hl
	inc	hl
	add	hl, bc
	ld	a, 5 (ix)
	ld	(hl), a
;SMSlib_spriteAdv.c:32: }
	pop	ix
	ret
;SMSlib_spriteAdv.c:34: void SMS_hideSprite (signed char sprite) {
;	---------------------------------
; Function SMS_hideSprite
; ---------------------------------
_SMS_hideSprite::
;SMSlib_spriteAdv.c:35: SpriteTableY[(unsigned char)sprite]=0xE0;          // move it offscreen
	ld	bc, #_SpriteTableY+0
	ld	iy, #2
	add	iy, sp
	ld	l, 0 (iy)
	ld	h, #0x00
	add	hl, bc
	ld	(hl), #0xe0
;SMSlib_spriteAdv.c:36: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
