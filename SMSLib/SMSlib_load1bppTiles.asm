;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_load1bppTiles
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_crt0_RST08
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_load1bppTiles
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
;SMSlib_load1bppTiles.c:9: void SMS_load1bppTiles (const void *src, unsigned int tilefrom, unsigned int size, unsigned char color0, unsigned char color1) {
;	---------------------------------
; Function SMS_load1bppTiles
; ---------------------------------
_SMS_load1bppTiles::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	dec	sp
;SMSlib_load1bppTiles.c:10: unsigned char *s=(unsigned char *)src;
	ld	b, 4 (ix)
	ld	e, 5 (ix)
;SMSlib_load1bppTiles.c:12: SMS_setAddr(0x4000|(tilefrom*32));
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	set	6, h
	rst	#0x08
;SMSlib_load1bppTiles.c:13: do {
	ld	a, 10 (ix)
	xor	a, 11 (ix)
	ld	-3 (ix), a
	ld	-2 (ix), b
	ld	-1 (ix), e
	ld	c, 8 (ix)
	ld	b, 9 (ix)
00111$:
;SMSlib_load1bppTiles.c:14: for (mask=0x01;mask<0x10;mask<<=1) {
	ld	e, #0x01
00118$:
;SMSlib_load1bppTiles.c:16: if (color1&mask)
	ld	a, 11 (ix)
	and	a, e
	ld	d, a
;SMSlib_load1bppTiles.c:15: if ((color0^color1)&mask)
	ld	a, -3 (ix)
	and	a,e
	jr	Z, 00108$
;SMSlib_load1bppTiles.c:17: SMS_byte_to_VDP_data(*s);
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
;SMSlib_load1bppTiles.c:16: if (color1&mask)
	inc	d
	dec	d
	jr	Z, 00102$
;SMSlib_load1bppTiles.c:17: SMS_byte_to_VDP_data(*s);
	out	(_VDPDataPort), a
	jr	00119$
00102$:
;SMSlib_load1bppTiles.c:19: SMS_byte_to_VDP_data(~*s);
	cpl
	out	(_VDPDataPort), a
	jr	00119$
00108$:
;SMSlib_load1bppTiles.c:21: if (color1&mask)
	ld	a, d
	or	a, a
	jr	Z, 00105$
;SMSlib_common.c:45: VDPDataPort=data;
	ld	a, #0xff
	out	(_VDPDataPort), a
;SMSlib_load1bppTiles.c:22: SMS_byte_to_VDP_data(0xff);
	jr	00119$
00105$:
;SMSlib_common.c:45: VDPDataPort=data;
	ld	a, #0x00
	out	(_VDPDataPort), a
;SMSlib_load1bppTiles.c:24: SMS_byte_to_VDP_data(0x00);
00119$:
;SMSlib_load1bppTiles.c:14: for (mask=0x01;mask<0x10;mask<<=1) {
	sla	e
	ld	a, e
	sub	a, #0x10
	jr	C, 00118$
;SMSlib_load1bppTiles.c:26: s++;
	inc	-2 (ix)
	jr	NZ, 00153$
	inc	-1 (ix)
00153$:
;SMSlib_load1bppTiles.c:27: } while (--size);
	dec	bc
	ld	a, b
	or	a, c
	jr	NZ, 00111$
;SMSlib_load1bppTiles.c:28: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
