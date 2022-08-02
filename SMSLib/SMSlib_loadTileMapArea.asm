;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_loadTileMapArea
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_crt0_RST08
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_loadTileMapArea
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
;SMSlib_loadTileMapArea.c:9: void SMS_loadTileMapArea (unsigned char x, unsigned char y, const void *src, unsigned char width, unsigned char height) {
;	---------------------------------
; Function SMS_loadTileMapArea
; ---------------------------------
_SMS_loadTileMapArea::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;SMSlib_loadTileMapArea.c:11: for (cur_y=y;cur_y<y+height;cur_y++) {
	ld	a, 5 (ix)
	ld	-1 (ix), a
	ld	b, 8 (ix)
	ld	a, b
	add	a, a
	ld	-4 (ix), a
00107$:
	ld	e, 5 (ix)
	ld	d, #0x00
	ld	l, 9 (ix)
	ld	h, #0x00
	add	hl, de
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jp	PO, 00133$
	xor	a, #0x80
00133$:
	jp	P, 00109$
;SMSlib_loadTileMapArea.c:13: SMS_setAddr(SMS_PNTAddress+(cur_y*32+x)*2);
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	l, 4 (ix)
	ld	h, #0x00
	add	hl, de
	add	hl, hl
	ld	de, #0x7800
	add	hl, de
	rst	#0x08
;SMSlib_loadTileMapArea.c:14: SMS_byte_brief_array_to_VDP_data(src,width*2);
	ld	c, -4 (ix)
	ld	a, 6 (ix)
	ld	-3 (ix), a
	ld	a, 7 (ix)
	ld	-2 (ix), a
	ld	e, -3 (ix)
	ld	d, -2 (ix)
;SMSlib_common.c:57: do {
00102$:
;SMSlib_common.c:58: VDPDataPort=*(data++);
	ld	a, (de)
	out	(_VDPDataPort), a
	inc	de
;SMSlib_common.c:59: } while (--size);
	dec	c
	jr	NZ, 00102$
;SMSlib_loadTileMapArea.c:15: src=(unsigned char*)src+width*2;
	ld	l, b
	ld	h, #0x00
	add	hl, hl
	ld	e, -3 (ix)
	ld	d, -2 (ix)
	add	hl, de
	ld	6 (ix), l
	ld	7 (ix), h
;SMSlib_loadTileMapArea.c:11: for (cur_y=y;cur_y<y+height;cur_y++) {
	inc	-1 (ix)
	jr	00107$
00109$:
;SMSlib_loadTileMapArea.c:17: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
