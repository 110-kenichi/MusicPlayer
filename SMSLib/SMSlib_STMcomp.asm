;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_STMcomp
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _STM_width
	.globl _STM_ttw
	.globl _STM_needRestore
	.globl _STM_oldHH
	.globl _STM_HH
	.globl _STM_dest
	.globl _STM_src
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_loadSTMcompressedTileMapatAddr
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
_STM_src::
	.ds 2
_STM_dest::
	.ds 2
_STM_HH::
	.ds 1
_STM_oldHH::
	.ds 1
_STM_needRestore::
	.ds 1
_STM_ttw::
	.ds 1
_STM_width::
	.ds 1
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
;SMSlib_STMcomp.c:18: void SMS_loadSTMcompressedTileMapatAddr (unsigned int dst, const void *src) {
;	---------------------------------
; Function SMS_loadSTMcompressedTileMapatAddr
; ---------------------------------
_SMS_loadSTMcompressedTileMapatAddr::
;SMSlib_STMcomp.c:19: STM_dest=dst;
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	ld	(_STM_dest+0), a
	ld	a, 1 (iy)
	ld	(_STM_dest+1), a
;SMSlib_STMcomp.c:20: STM_src=(unsigned char *)(src);
	ld	a, 2 (iy)
	inc	iy
	inc	iy
	ld	(_STM_src+0), a
	ld	a, 1 (iy)
	ld	(_STM_src+1), a
;SMSlib_STMcomp.c:21: STM_width=*STM_src++;
	ld	hl, (_STM_src)
	ld	a, (hl)
	ld	(_STM_width+0), a
	ld	hl, (_STM_src)
	inc	hl
	ld	(_STM_src), hl
;SMSlib_STMcomp.c:22: STM_ttw=STM_width;
	ld	a,(#_STM_width + 0)
	ld	iy, #_STM_ttw
	ld	0 (iy), a
;SMSlib_STMcomp.c:23: STM_HH=0;
	ld	iy, #_STM_HH
	ld	0 (iy), #0x00
;SMSlib_STMcomp.c:24: STM_oldHH=0;
	ld	iy, #_STM_oldHH
	ld	0 (iy), #0x00
;SMSlib_STMcomp.c:25: STM_needRestore=0;
	ld	iy, #_STM_needRestore
	ld	0 (iy), #0x00
;SMSlib_STMcomp.c:175: __endasm;
	ld	hl,(#_STM_dest)
	call	_SMS_crt0_RST08
	_STM_loop:
	ld	hl,(#_STM_src)
	ld	a,(hl)
	inc	hl
	ld	(#_STM_src),hl
	rra
	jr	nc,_STM_noRLE
	rra
	jr	nc,_STM_RLE
;	***************** RLE of successive words
	and	#0x3F ; keep only last 6 bits (counter)
	add	a,#2
	ld	b,a ; b = cnt
	ld	a,(#_STM_HH)
	ld	d,a ; d = high part of tile
	ld	e,(hl) ; e = low part of tile
	inc	hl
	ld	(#_STM_src),hl ; src++
	ld	hl,#_STM_ttw
	ld	c,(hl) ; c = ttw
	_STM_inc_RLE_loop:
	ld	a,e ; write tile to VRAM respecting access time costraints
	out	(#0xBE),a ; 11
	ld	a,d ; 4
	sub	#0 ; *delay* 7
	dec	c ; ttw-- 4 = 26 (VRAM SAFE)
	out	(#0xBE),a
	call	z,_STM_setAddr ; ttw==0?
	dec	b
	jr	z,_STM_inc_RLE_done ; cnt==0?
	inc	de ; tile++
	jr	_STM_inc_RLE_loop
	_STM_inc_RLE_done:
	ld	hl,#_STM_HH ; save high part of tile
	ld	(hl),d
	ld	hl,#_STM_ttw ; save ttw
	ld	(hl),c
	_STM_check_restore:
	ld	a,(#_STM_needRestore)
	or	a
	jr	z,_STM_loop
	xor	a
	ld	(#_STM_needRestore),a
	ld	a,(#_STM_oldHH)
	ld	(#_STM_HH),a
	jr	_STM_loop
	_STM_noRLE:
	rra
	jr	nc,_STM_RAW
;	***************** special
	rra
	jr	nc,_STM_no_temp_HH
	ld	b,a
	ld	a,(#_STM_HH)
	ld	(#_STM_oldHH),a
	ld	a,#1
	ld	(#_STM_needRestore),a
	ld	a,b
	_STM_no_temp_HH:
	and	#0x1F ; keep only last 5 bits
	ld	(#_STM_HH),a
	jr	_STM_loop
	_STM_RLE:
; ***************** RLE
	and	#0x3F ; keep only last 6 bits (counter)
	add	a,#2
	ld	b,a ; b = cnt
	ld	a,(#_STM_HH)
	ld	d,a ; d = high part of tile
	ld	e,(hl) ; e = low part of tile
	inc	hl
	ld	(#_STM_src),hl ; src++
	ld	hl,#_STM_ttw
	ld	c,(hl) ; c = ttw
	_STM_RLE_loop:
	ld	a,e ; write tile to VRAM respecting access time costraints
	out	(#0xBE),a ; 11
	ld	a,d ; 4
	sub	#0 ; *delay* 7
	dec	c ; ttw-- 4 = 26 (VRAM SAFE)
	out	(#0xBE),a
	call	z,_STM_setAddr ; ttw==0?
	dec	b
	jr	nz,_STM_RLE_loop ; cnt==0?
	ld	hl,#_STM_ttw ; save ttw
	ld	(hl),c
	jr	_STM_check_restore
	_STM_RAW:
; ***************** RAW
	and	#0x3F ; keep only last 6 bits (counter)
	or	a
	jr	z,_STM_leave ; if cnt is 0 - end of STM
	ld	b,a ; b = cnt
	ld	hl,#_STM_ttw
	ld	c,(hl) ; c = ttw
	_STM_RAW_loop:
	ld	hl,(#_STM_src)
	ld	a,(hl)
	out	(#0xBE),a ; 11 low part of tile
	inc	hl ; 6
	ld	(#_STM_src),hl ; 16 src++
	ld	a,(#_STM_HH) ; 13 high part of tile
	out	(#0xBE),a ; xx = VRAM safe
	dec	c
	call	z,_STM_setAddr
	dec	b
	jr	nz,_STM_RAW_loop
	ld	hl,#_STM_ttw
	ld	(hl),c
	jr	_STM_check_restore
	_STM_setAddr:
	ld	hl,(#_STM_dest)
	ld	a,b ; preserve b
	ld	bc,#64
	add	hl,bc
	ld	b,a ; restore b
	ld	(#_STM_dest),hl
	ld	c,#0xBF ; set VDP Control Port
	di	; make it interrupt SAFE
	out	(c),l
	out	(c),h
	ei
	ld	a,(#_STM_width)
	ld	(#_STM_ttw),a
	ld	c,a
	ret
	_STM_leave:
;SMSlib_STMcomp.c:176: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
