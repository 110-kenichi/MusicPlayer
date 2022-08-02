;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_spriteClip
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _clipWin_y1
	.globl _clipWin_x1
	.globl _clipWin_y0
	.globl _clipWin_x0
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_setClippingWindow
	.globl _SMS_addSpriteClipping
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
_clipWin_x0::
	.ds 1
_clipWin_y0::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_clipWin_x1::
	.ds 1
_clipWin_y1::
	.ds 1
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
;SMSlib_spriteClip.c:20: void SMS_setClippingWindow (unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1) {
;	---------------------------------
; Function SMS_setClippingWindow
; ---------------------------------
_SMS_setClippingWindow::
;SMSlib_spriteClip.c:21: clipWin_x0=x0;
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	ld	(_clipWin_x0+0), a
;SMSlib_spriteClip.c:22: clipWin_y0=y0;
	ld	a, 1 (iy)
	inc	iy
	ld	(_clipWin_y0+0), a
;SMSlib_spriteClip.c:23: clipWin_x1=x1;
	ld	a, 1 (iy)
	inc	iy
	ld	(_clipWin_x1+0), a
;SMSlib_spriteClip.c:24: clipWin_y1=y1;
	ld	a, 1 (iy)
	ld	(_clipWin_y1+0), a
;SMSlib_spriteClip.c:25: }
	ret
;SMSlib_spriteClip.c:27: signed char SMS_addSpriteClipping (int x, int y, unsigned char tile) {
;	---------------------------------
; Function SMS_addSpriteClipping
; ---------------------------------
_SMS_addSpriteClipping::
	push	ix
	ld	ix,#0
	add	ix,sp
;SMSlib_spriteClip.c:29: if ( (SpriteNextFree>=MAXSPRITES) ||                                    // no sprite left?
	ld	a,(#_SpriteNextFree + 0)
	sub	a, #0x40
	jp	NC, 00101$
;SMSlib_spriteClip.c:30: (x>clipWin_x1) || (x<((int)(clipWin_x0)-(int)(spritesWidth))) ||   // clipped by x?
	ld	a,(#_clipWin_x1 + 0)
	ld	b, #0x00
	sub	a, 4 (ix)
	ld	a, b
	sbc	a, 5 (ix)
	jp	PO, 00141$
	xor	a, #0x80
00141$:
	jp	M, 00101$
	ld	a,(#_clipWin_x0 + 0)
	ld	c, #0x00
	ld	iy, #_spritesWidth
	ld	b, 0 (iy)
	ld	e, #0x00
	sub	a, b
	ld	b, a
	ld	a, c
	sbc	a, e
	ld	c, a
	ld	a, 4 (ix)
	sub	a, b
	ld	a, 5 (ix)
	sbc	a, c
	jp	PO, 00142$
	xor	a, #0x80
00142$:
	jp	M, 00101$
;SMSlib_spriteClip.c:31: (x<0) ||                                                           // x negative?
	bit	7, 5 (ix)
	jr	NZ, 00101$
;SMSlib_spriteClip.c:32: (y>clipWin_y1) || (y<((int)(clipWin_y0)-(int)(spritesHeight))) ||  // clipped by y?
	ld	a,(#_clipWin_y1 + 0)
	ld	b, #0x00
	sub	a, 6 (ix)
	ld	a, b
	sbc	a, 7 (ix)
	jp	PO, 00143$
	xor	a, #0x80
00143$:
	jp	M, 00101$
	ld	a,(#_clipWin_y0 + 0)
	ld	c, #0x00
	ld	iy, #_spritesHeight
	ld	b, 0 (iy)
	ld	e, #0x00
	sub	a, b
	ld	b, a
	ld	a, c
	sbc	a, e
	ld	c, a
	ld	a, 6 (ix)
	sub	a, b
	ld	a, 7 (ix)
	sbc	a, c
	jp	PO, 00144$
	xor	a, #0x80
00144$:
	jp	M, 00101$
;SMSlib_spriteClip.c:33: ((y-1)==0xD0) )                                                    // y-1 is 0xD1?
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	dec	bc
	ld	a, c
	sub	a, #0xd0
	or	a, b
	jr	NZ, 00102$
00101$:
;SMSlib_spriteClip.c:34: return (-1);                                                          // sprite clipped!
	ld	l, #0xff
	jr	00109$
00102$:
;SMSlib_spriteClip.c:35: SpriteTableY[SpriteNextFree]=y-1;
	ld	bc, #_SpriteTableY+0
	ld	hl, (_SpriteNextFree)
	ld	h, #0x00
	add	hl, bc
	ld	a, 6 (ix)
	dec	a
	ld	(hl), a
;SMSlib_spriteClip.c:36: stXN=&SpriteTableXN[SpriteNextFree*2];
	ld	iy, #_SpriteNextFree
	ld	l, 0 (iy)
	ld	h, #0x00
	add	hl, hl
	ld	de, #_SpriteTableXN
	add	hl, de
;SMSlib_spriteClip.c:37: *stXN++=x;
	ld	a, 4 (ix)
	ld	(hl), a
	inc	hl
;SMSlib_spriteClip.c:38: *stXN=tile;
	ld	a, 8 (ix)
	ld	(hl), a
;SMSlib_spriteClip.c:39: return(SpriteNextFree++);
	ld	c, 0 (iy)
	inc	0 (iy)
	ld	l, c
00109$:
;SMSlib_spriteClip.c:40: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__clipWin_x1:
	.db #0xff	; 255
__xinit__clipWin_y1:
	.db #0xbf	; 191
	.area _CABS (ABS)
