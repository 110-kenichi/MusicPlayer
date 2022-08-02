;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_loadTiles
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_crt0_RST08
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_loadTiles
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
;SMSlib_loadTiles.c:9: void SMS_loadTiles (const void *src, unsigned int tilefrom, unsigned int size) {
;	---------------------------------
; Function SMS_loadTiles
; ---------------------------------
_SMS_loadTiles::
;SMSlib_loadTiles.c:11: SMS_setAddr(0x4000|(tilefrom*32));
	ld	hl, #4
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	set	6, h
	rst	#0x08
;SMSlib_loadTiles.c:12: SMS_byte_array_to_VDP_data(src,size);
	ld	iy, #6
	add	iy, sp
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	ld	iy, #2
	add	iy, sp
	ld	e, 0 (iy)
	ld	d, 1 (iy)
;SMSlib_common.c:50: do {
00101$:
;SMSlib_common.c:51: VDPDataPort=*(data++);
	ld	a, (de)
	out	(_VDPDataPort), a
	inc	de
;SMSlib_common.c:52: } while (--size);
	dec	bc
	ld	a, b
	or	a, c
	jr	NZ, 00101$
;SMSlib_loadTiles.c:12: SMS_byte_array_to_VDP_data(src,size);
;SMSlib_loadTiles.c:13: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
