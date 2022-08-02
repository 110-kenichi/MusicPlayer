export PATH := $(PATH):"/mnt/c/Program Files/SDCC/bin"

PROGRAM = MuPlayer.sms
CC = sdcc.exe
CFLAGS = -c -mz80 --std-c2x --opt-code-speed --debug 
#OBJS =  main.rel Types.rel font.rel sound.rel video.rel font.rel font_tile.rel PSGLib.rel logo_code.rel logo_tile.rel title_code.rel title_tile.rel sel_code.rel sel_tile.rel 
OBJS =  main.rel Types.rel font.rel video.rel font.rel font_tile.rel logo_code.rel logo_tile.rel heatshrink_decoder.rel VGM.rel Data1.rel Data2.rel Data3.rel 

.SUFFIXES: .c .rel .asm

.PHONY: all
all: depend $(PROGRAM)

$(PROGRAM): crt0b_sms.rel $(OBJS)
	$(CC) -o MuPlayer.ihx -mz80 --no-std-crt0 --data-loc 0xC000\
	 SMSLib/SMSlib.lib\
	 -Wl-b_BANK_C1=0x14000\
	 -Wl-b_BANK_C2=0x24000\
	 -Wl-b_BANK_D1=0x38000\
	 -Wl-b_BANK_MD1=0x48000\
	 -Wl-b_BANK_MD2=0x58000\
	 -Wl-b_BANK_MD3=0x68000\
	 $^
	makesms.exe MuPlayer.ihx MuPlayer.sms
	cmd.exe /C copy.bat
#	/mnt/e/Emu/Emulicious/Emulicious.exe MuPlayer.sms
#	/mnt/e/Emu/Fusion/Fusion.exe MuPlayer.sms

.PHONY: run
run:
	cmd.exe /C copy.bat
	/mnt/e/Emu/Emulicious/Emulicious.exe MuPlayer.sms
#	/mnt/e/Emu/Fusion/Fusion.exe MuPlayer.sms

logo_tile.rel: logo_tile.c 
	sdcc.exe $(CFLAGS) --constseg BANK_D1 logo_tile.c

#title_tile.rel: title_tile.c 
#	sdcc.exe $(CFLAGS) --constseg BANK_D2 title_tile.c

#sel_tile.rel: sel_tile.c 
#	sdcc.exe $(CFLAGS) --constseg BANK_D3 sel_tile.c

Data1.rel: Data1.c
	sdcc.exe $(CFLAGS) --constseg BANK_MD1 Data1.c
Data2.rel: Data2.c
	sdcc.exe $(CFLAGS) --constseg BANK_MD2 Data2.c
Data3.rel: Data3.c
	sdcc.exe $(CFLAGS) --constseg BANK_MD3 Data3.c

crt0b_sms.rel: crt0b_sms.s
	sdasz80.exe -g -y -o crt0b_sms.rel crt0b_sms.s

.c.rel: 
	$(CC) $(CFLAGS) $<

.PHONY: clean
clean:
	rm $(PROGRAM) $(OBJS) *.lst *.sym *.asm

.PHONY: depend
depend: $(OBJS:.rel=.c)
	-@ rm depend.inc
	-@ for i in $^; do cpp -MM $$i | sed "s/\ [_a-zA-Z0-9][_a-zA-Z0-9]*\.c//g" >> depend.inc; done

-include depend.inc
