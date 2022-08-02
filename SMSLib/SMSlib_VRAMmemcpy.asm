;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_VRAMmemcpy
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_VRAMmemcpy
	.globl _SMS_VRAMmemcpy_brief
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
;SMSlib_VRAMmemcpy.c:13: void SMS_VRAMmemcpy (unsigned int dst, const void *src, unsigned int size) {
;	---------------------------------
; Function SMS_VRAMmemcpy
; ---------------------------------
_SMS_VRAMmemcpy::
;SMSlib_VRAMmemcpy.c:42: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	l, 4 (ix)
	ld	a, 5 (ix)
	set	6, a
	ld	h, a
	rst	#0x08
	ld	l,6 (ix)
	ld	h,7 (ix)
	ld	a,8 (ix) ; ((unsigned char)(size))
	or	a
	ld	b,a
	ld	a,9 (ix) ; (((size)>>8))
	jr	Z,noinc ; if ((unsigned char)(size)) is zero, do not inc (((size)>>8))
	inc	a ; inc (((size)>>8)) because ((unsigned char)(size)) is not zero
	noinc:
	ld	c,#_VDPDataPort
	copyloop:
	outi
	jp	nz,copyloop ; 10 = 26 (VRAM safe)
	dec	a
	jp	nz,copyloop
	pop	ix
;SMSlib_VRAMmemcpy.c:43: }
	ret
;SMSlib_VRAMmemcpy.c:45: void SMS_VRAMmemcpy_brief (unsigned int dst, const void *src, unsigned char size) {
;	---------------------------------
; Function SMS_VRAMmemcpy_brief
; ---------------------------------
_SMS_VRAMmemcpy_brief::
;SMSlib_VRAMmemcpy.c:65: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
;SMSlib_VRAMmemcpy.c:12:	SMS_crt0_RST08(0x4000|dst);
	ld	l, 4 (ix)
	ld	a, 5 (ix)
	set	6, a
	ld	h, a
	rst	#0x08
;SMSlib_VRAMmemcpy.c:13:	SMS_byte_brief_array_to_VDP_data(src,size);
	ld	l,6 (ix)
	ld	h,7 (ix)
	ld	b,8 (ix) ; size
	copyloop_brief:
	outi	; 16
	jp	nz,copyloop_brief ; 10 = 26 (VRAM safe)
	pop	ix
;SMSlib_VRAMmemcpy.c:66: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
