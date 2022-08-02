;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_paletteAdv
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_loadBGPaletteHalfBrightness
	.globl _SMS_zeroBGPalette
	.globl _SMS_loadSpritePaletteHalfBrightness
	.globl _SMS_zeroSpritePalette
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
;SMSlib_paletteAdv.c:12: void SMS_loadBGPaletteHalfBrightness (const void *palette) __z88dk_fastcall {
;	---------------------------------
; Function SMS_loadBGPaletteHalfBrightness
; ---------------------------------
_SMS_loadBGPaletteHalfBrightness::
;SMSlib_paletteAdv.c:14: ASM_LD_DE_IMM(#SMS_CRAMAddress);
	ld de,#0xC000 
;SMSlib_paletteAdv.c:15: ASM_DE_TO_VDP_CONTROL;
	ld c,#_VDPControlPort 
	di 
	out (c),e 
	out (c),d 
	ei 
;SMSlib_paletteAdv.c:16: ASM_LD_B_IMM(#16);
	ld b,#16 
;SMSlib_paletteAdv.c:24: __endasm;
	1$:
	ld a,(hl) ; 7
	rrca	; 4
	and	#0x15 ; 7
	out	(_VDPDataPort),a ; 11
	inc	hl ; 6
	djnz	1$ ; 13 = *VRAM SAFE*
;SMSlib_paletteAdv.c:25: }
	ret
;SMSlib_paletteAdv.c:27: void SMS_zeroBGPalette (void) {
;	---------------------------------
; Function SMS_zeroBGPalette
; ---------------------------------
_SMS_zeroBGPalette::
;SMSlib_paletteAdv.c:28: ASM_LD_DE_IMM(#SMS_CRAMAddress);
	ld de,#0xC000 
;SMSlib_paletteAdv.c:29: ASM_DE_TO_VDP_CONTROL;
	ld c,#_VDPControlPort 
	di 
	out (c),e 
	out (c),d 
	ei 
;SMSlib_paletteAdv.c:30: ASM_LD_B_IMM(#16);
	ld b,#16 
;SMSlib_paletteAdv.c:36: __endasm;
	xor	a
	1$:
	out (_VDPDataPort),a ; 11
	nop	; 4
	djnz	1$ ; 13 = 28 *VRAM SAFE*
;SMSlib_paletteAdv.c:37: }
	ret
;SMSlib_paletteAdv.c:39: void SMS_loadSpritePaletteHalfBrightness (const void *palette) __z88dk_fastcall {
;	---------------------------------
; Function SMS_loadSpritePaletteHalfBrightness
; ---------------------------------
_SMS_loadSpritePaletteHalfBrightness::
;SMSlib_paletteAdv.c:41: ASM_LD_DE_IMM(#SMS_CRAMAddress+0x10);
	ld de,#0xC000 +0x10 
;SMSlib_paletteAdv.c:42: ASM_DE_TO_VDP_CONTROL;
	ld c,#_VDPControlPort 
	di 
	out (c),e 
	out (c),d 
	ei 
;SMSlib_paletteAdv.c:43: ASM_LD_B_IMM(#16);
	ld b,#16 
;SMSlib_paletteAdv.c:51: __endasm;
	1$:
	ld a,(hl) ; 7
	rrca	; 4
	and	#0x15 ; 7
	out	(_VDPDataPort),a ; 11
	inc	hl ; 6
	djnz	1$ ; 13 *VRAM SAFE*
;SMSlib_paletteAdv.c:52: }
	ret
;SMSlib_paletteAdv.c:54: void SMS_zeroSpritePalette (void) {
;	---------------------------------
; Function SMS_zeroSpritePalette
; ---------------------------------
_SMS_zeroSpritePalette::
;SMSlib_paletteAdv.c:55: ASM_LD_DE_IMM(#SMS_CRAMAddress+0x10);
	ld de,#0xC000 +0x10 
;SMSlib_paletteAdv.c:56: ASM_DE_TO_VDP_CONTROL;
	ld c,#_VDPControlPort 
	di 
	out (c),e 
	out (c),d 
	ei 
;SMSlib_paletteAdv.c:57: ASM_LD_B_IMM(#16);
	ld b,#16 
;SMSlib_paletteAdv.c:63: __endasm;
	xor	a
	1$:
	out (_VDPDataPort),a ; 11
	nop	; 4
	djnz	1$ ; 13 = 28 *VRAM SAFE*
;SMSlib_paletteAdv.c:64: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
