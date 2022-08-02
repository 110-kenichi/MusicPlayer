;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module SMSlib_sprite
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _SMS_crt0_RST08
	.globl _SpriteNextFree
	.globl _SpriteTableXN
	.globl _SpriteTableY
	.globl _SMS_SRAM
	.globl _SRAM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot2
	.globl _ROM_bank_to_be_mapped_on_slot1
	.globl _SMS_initSprites
	.globl _SMS_addSprite
	.globl _SMS_copySpritestoSAT
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
_SpriteTableY::
	.ds 64
_SpriteTableXN::
	.ds 128
_SpriteNextFree::
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
;SMSlib_sprite.c:13: void SMS_initSprites (void) {
;	---------------------------------
; Function SMS_initSprites
; ---------------------------------
_SMS_initSprites::
;SMSlib_sprite.c:14: SpriteNextFree=0;
	ld	a, #0x00
	ld	(#_SpriteNextFree), a
;SMSlib_sprite.c:15: }
	ret
;SMSlib_sprite.c:58: signed char SMS_addSprite (unsigned char x, unsigned char y, unsigned char tile) __naked __preserves_regs(iyh,iyl) {
;	---------------------------------
; Function SMS_addSprite
; ---------------------------------
_SMS_addSprite::
;SMSlib_sprite.c:101: __endasm;
	ld	a,(#_SpriteNextFree)
	cp	a,#64
	jr	nc,_returnInvalidHandle1 ; no sprites left, leave!
	ld	c,a ; save SpriteNextFree value in c
	ld	hl,#2
	add	hl,sp
	ld	e,(hl) ; read X
	inc	hl
	ld	a,(hl) ; read Y
	cp	a,#0xd1
	jr	z,_returnInvalidHandle2 ; invalid Y, leave!
	inc	hl
	ld	d,(hl) ; read tile number
	ld	hl,#_SpriteTableY
	ld	b,#0x00
	add	hl,bc ; hl+=SpriteNextFree
	dec	a
	ld	(hl),a ; write Y (as Y-1)
	ld	hl,#_SpriteTableXN
	ld	a,c ; save sprite handle to A
	sla	c
	add	hl,bc ; hl+=(SpriteNextFree*2)
	ld	(hl),e ; write X
	inc	hl
	ld	(hl),d ; write tile number
	ld	l,a ; sprite handle to return
	inc	a ; increment and
	ld	(#_SpriteNextFree),a ; save SpriteNextFree value
	ret
	_returnInvalidHandle1:
	ld	l,#0xff
	ret
	_returnInvalidHandle2:
	ld	l,#0xfe
	ret
;SMSlib_sprite.c:102: }
;SMSlib_sprite.c:106: void SMS_copySpritestoSAT (void) {
;	---------------------------------
; Function SMS_copySpritestoSAT
; ---------------------------------
_SMS_copySpritestoSAT::
;SMSlib_sprite.c:118: SMS_setAddr(SMS_SATAddress);
	ld	hl, #0x7f00
	rst	#0x08
;SMSlib_sprite.c:134: __endasm;
	ld	a,(#_SpriteNextFree)
	or	a
	jr	z,_no_sprites
	ld	b,a
	ld	c,#_VDPDataPort
	ld	hl,#_SpriteTableY
	_next_spriteY:
	outi	; 16 cycles
	jp	nz,_next_spriteY ; 10 cycles => VRAM safe
	cp	#64 ; 7 cycles
	jr	z,_no_sprite_term ; 7 cycles
	ld	a,#0xD0 ; 7 cycles => VRAM safe
	out	(c),a
	_no_sprite_term:
;SMSlib_sprite.c:135: SMS_setAddr(SMS_SATAddress+128);
	ld	hl, #0x7f80
	rst	#0x08
;SMSlib_sprite.c:150: __endasm;
	ld	c,#_VDPDataPort
	ld	a,(#_SpriteNextFree)
	add	a,a
	ld	b,a
	ld	hl,#_SpriteTableXN
	_next_spriteXN:
	outi	; 16 cycles
	jp	nz,_next_spriteXN ; 10 cycles => VRAM safe
	ret
	_no_sprites:
	ld	a,#0xD0
	out	(#_VDPDataPort),a
;SMSlib_sprite.c:151: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
