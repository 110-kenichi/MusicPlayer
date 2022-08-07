#include "heatshrink_decoder.h"
#include "Font.h"
#include "main.h"
#include "VGM.h"

#pragma codeseg BANK_C2

struct MusicData music_data[] =
{
    {DATA_BANK_S + 1, 0, &Fantasy_Zone___12___Last_Boss_Size, Fantasy_Zone___12___Last_Boss_Data,
        "1.FANTASY ZONE - LAST BOSS      "},
    {DATA_BANK_S + 2, 1, &Out_Run__FM____01___Magical_Sound_Shower_Size, Out_Run__FM____01___Magical_Sound_Shower_Data,
        "2.OUTRUN - MAGICAL SOUND SHOWER "},
    {DATA_BANK_S + 3, 1, &Fantasy_Zone_II__FM____Fuwareak_Size, Fantasy_Zone_II__FM____Fuwareak_Data,
        "3.FANTASY ZONE II - FUWAREAK    "},
};

struct OutputData output_data_psg[] =
{
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0}
};

struct OutputData output_data_opll[] =
{
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},


    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
    {0, 0x0, 0xf, 0, 0},
};

static unsigned char loop_mode = LoopMode_All;

static unsigned char time_fps = 00;
static struct ElapseData time_min_sec;

static unsigned char rhythm_mode = 0x00;

static short music_selected_no;
static short music_current_no;

static unsigned char music_current_stat = 0;
static unsigned char music_command = PlayerCommand_None;
static unsigned char music_notify = 0;

static const unsigned char *data_current_vgmData;
static unsigned short data_current_vgmDataSize;
static unsigned char data_current_vgmDataCompressed;

static unsigned short data_current_pos;
static unsigned short data_loop_ofs;
static unsigned short data_begin_ofs;
static unsigned char data_waitN;
static unsigned char data_waitOne;

static void set_enable(unsigned char data) __naked
{
    __asm__("ld iy,#2");
    __asm__("add iy,sp"); //Bypass the return address of the function 

    __asm__("ld d,(iy)");//   ;data

    __asm__("LD  C, #0xf2");
    __asm__("OUT (C), D");

    __asm__("ret");
}

static void InitTime()
{
    time_fps = 0;
    time_min_sec.sec0 = 0;
    time_min_sec.sec1 = 0;
    time_min_sec.min0 = 0;
    time_min_sec.min1 = 0;
}

inline static void PrintTime()
{
    SMS_setNextTileatXY(26, 17);
    SMS_setTile(time_min_sec.min1 + DATA_ROOT + FONT_TILES_NO_S);
    SMS_setNextTileatXY(27, 17);
    SMS_setTile(time_min_sec.min0 + DATA_ROOT + FONT_TILES_NO_S);

    SMS_setNextTileatXY(28, 17);
    SMS_setTile(':' - 33 + FONT_TILES_NO_S);

    SMS_setNextTileatXY(29, 17);
    SMS_setTile(time_min_sec.sec1 + DATA_ROOT + FONT_TILES_NO_S);
    SMS_setNextTileatXY(30, 17);
    SMS_setTile(time_min_sec.sec0 + DATA_ROOT + FONT_TILES_NO_S);    
}

inline static void IncrementTime()
{
    time_fps++;
    if(time_fps >= 60)
    {
        time_fps=0;
        time_min_sec.sec0++;
        if(time_min_sec.sec0 >= 10)
        {
            time_min_sec.sec0 = 0;
            time_min_sec.sec1++;
            if(time_min_sec.sec1 >= 6)
            {
                time_min_sec.sec1 = 0;
                time_min_sec.min0++;
                if(time_min_sec.min0 >= 10)
                {
                    time_min_sec.min0 = 0;
                    time_min_sec.min1++;
                    if(time_min_sec.min1 >= 10)
                        time_min_sec.min1 = 0;
                }
            }
        }
    }
}

static heatshrink_decoder *hsd = 0;
static uint8_t out_buf[OUT_BUFFER_SIZE*4];
static uint8_t *out_buf_ptr;
static size_t poll_sz = 0;
static size_t total_read = 0;

static inline void UpdateDecodedData()
{
    if(data_current_vgmDataCompressed)
    {
        if(out_buf_ptr == out_buf + poll_sz)
        {
            size_t sink_sz = 0;
            heatshrink_decoder_sink(hsd, data_current_vgmData, data_current_vgmDataSize, &sink_sz);
            data_current_vgmData += sink_sz;
            data_current_vgmDataSize -= sink_sz;

            heatshrink_decoder_poll(hsd, out_buf, OUT_BUFFER_SIZE, &poll_sz);
            out_buf_ptr = out_buf;
        }
    }
}

static unsigned char ReadDecodedData()
{
    if(data_current_vgmDataCompressed)
    {
        UpdateDecodedData();
        total_read++;
        return *out_buf_ptr++;
    }else{
        return *data_current_vgmData++;
    }
}

static inline unsigned char PeekDecodedData()
{
    if(data_current_vgmDataCompressed)
    {
        UpdateDecodedData();
        return *out_buf_ptr;
    }else{
        return *data_current_vgmData;
    }
}

static void InitDecoder()
{
    data_current_pos = 0x0;
    data_loop_ofs = 0x0;
    data_waitN = 0;
    data_waitOne = 0;

    SMS_mapROMBank(music_data[music_current_no].bank_no);

    data_current_vgmDataCompressed = music_data[music_current_no].compressed;
    data_current_vgmData = music_data[music_current_no].data;
    data_current_vgmDataSize = *music_data[music_current_no].size;

    if(hsd == 0)
        hsd = heatshrink_decoder_alloc(512, 11, 4);
    heatshrink_decoder_reset(hsd);

    //heatshrink_decoder_finish(&hsd);
    poll_sz = 0;
    out_buf_ptr = out_buf;
    total_read = 0;

    set_enable(ReadDecodedData());
}

static inline void SeekDecodedData(unsigned short position)
{
    InitDecoder();
#if 0
    if(data_current_vgmDataCompressed)
    {
        while(total_read < position - 1 - (OUT_BUFFER_SIZE*4))
        {
            size_t sink_sz = 0;
            heatshrink_decoder_sink(hsd, data_current_vgmData, data_current_vgmDataSize, &sink_sz);
            data_current_vgmData += sink_sz;
            data_current_vgmDataSize -= sink_sz;

            heatshrink_decoder_poll(hsd, out_buf, (OUT_BUFFER_SIZE*4), &poll_sz);
            out_buf_ptr = out_buf;
            total_read += poll_sz;
        }
        while(total_read < position - 1)
            ReadDecodedData();
    }else{
        data_current_vgmData += position - 1;
    }
#endif
}

static void VGMSoundOff()
{
    IOPortOPSG = 0b10011111;
    IOPortOPSG = 0b10111111;
    IOPortOPSG = 0b11011111;
    IOPortOPSG = 0b11111111;

    for(int i=0;i<4;i++)
        output_data_psg[i].volume = 0xf;
    for(int i=0;i<12;i++)
        output_data_opll[i].volume = 0xf;

    for(int i=0;i<9;i++)
    {
        IOPortOPLL1 = 0x30+i;
        IOPortOPLL2 = 0x0f;
    }

    IOPortOPLL1 = 0x36;
    IOPortOPLL2 = 0xff;
    IOPortOPLL1 = 0x37;
    IOPortOPLL2 = 0xff;
    IOPortOPLL1 = 0x38;
    IOPortOPLL2 = 0xff;
}

inline static void WritePsgData()
{
    register unsigned char wdata = ReadDecodedData();
    IOPortOPSG = wdata;
    if((wdata & 0b10010000) == 0b10010000)
    {
        switch(wdata & 0b01100000)
        {
            case 0b00000000:
                output_data_psg[0].volume = (wdata & 0xf);
                break;
            case 0b00100000:
                output_data_psg[1].volume = (wdata & 0xf);
                break;
            case 0b01000000:
                output_data_psg[2].volume = (wdata & 0xf);
                break;
            case 0b01100000:
                output_data_psg[3].volume = (wdata & 0xf);
                break;
        }
    }    
}

inline static void WriteOpllData(unsigned char cmd)
{
    IOPortOPLL1 = cmd;
    {
        register unsigned char wdata = ReadDecodedData();
        IOPortOPLL2 = wdata;

        switch(cmd)
        {
            case 0xe:
                rhythm_mode = wdata & 0b100000;
                if(wdata & 0x16)    //BD
                    output_data_opll[7].volume = output_data_opll[7].keyon;
                if(wdata & 0x8)     //SD
                    output_data_opll[8].volume = output_data_opll[8].keyon;
                if(wdata & 0x1)     //HH
                    output_data_opll[9].volume = output_data_opll[9].keyon;
                if(wdata & 0x2)     //TCYM
                    output_data_opll[10].volume = output_data_opll[10].keyon;
                if(wdata & 0x4)     //TOM
                    output_data_opll[11].volume = output_data_opll[11].keyon;
                break;
                //key on
            case 0x20:
            case 0x21:
            case 0x22:
            case 0x23:
            case 0x24:
            case 0x25:
            case 0x26:
            case 0x27:
            case 0x28:
                if(wdata & 0b00010000)
                    output_data_opll[cmd-0x20].volume =  output_data_opll[cmd-0x20].keyon;
                break;
                //volume
            case 0x30:
            case 0x31:
            case 0x32:
            case 0x33:
            case 0x34:
            case 0x35:
                if(wdata & 0b00010000)
                    output_data_opll[cmd-0x30].keyon = (wdata & 0xf);
                break;
            case 0x36:
                //BD
                if(rhythm_mode)
                {
                    output_data_opll[7].keyon = (wdata & 0xf);
                }else{
                    if(wdata & 0b00010000)
                        output_data_opll[6].keyon = (wdata & 0xf);
                }
                break;
            case 0x37:
                //SD,HH
                if(rhythm_mode)
                {
                    output_data_opll[8].keyon = (wdata & 0xf);
                    output_data_opll[9].keyon = wdata >> 4;
                }else{
                    if(wdata & 0b00010000)
                        output_data_opll[7].keyon = (wdata & 0xf);
                }
                break;
            case 0x38:
                //TCYM,TOM
                if(rhythm_mode)
                {
                    output_data_opll[10].keyon = (wdata & 0xf);
                    output_data_opll[11].keyon = wdata >> 4;
                }else{
                    if(wdata & 0b00010000)
                        output_data_opll[8].keyon = (wdata & 0xf);
                }
                break;
        }
    }    
}

void VGMUpdate()
{
    switch(music_command)
    {
        case PlayerCommand_Stop:
        {
            VGMSoundOff();
            for(int i=0;i<9;i++)
            {
                IOPortOPLL1 = 0x20+i;
                IOPortOPLL2 = 0x0;
            }
            InitTime();

            music_command = PlayerCommand_None;
            music_current_stat = PlayerStatus_Stop;
            break;
        }
        case PlayerCommand_Play:
        {
            VGMSoundOff();
            InitDecoder();
            InitTime();

            music_command = PlayerCommand_None;
            music_current_stat = PlayerStatus_Play;
            break;
        }
        default:
            break;
    }

    if(music_current_stat == PlayerStatus_Stop)
        return;
    if(data_current_pos == 0xffff)
        return;

    IncrementTime();

    if(data_waitN)
    {
        data_waitN--;
        return;
    }

    while(1){
        register unsigned char cmd = PeekDecodedData();
        if(cmd != 0xff)
        {
            if(data_waitOne)
            {
                cmd = cmd & ~0x40;
                data_waitOne = 0;
            }else if(cmd & 0x40)
            {
                data_waitOne = 1;
                return;
            }
            ReadDecodedData();
            switch(cmd)
            {
                case 0x39:
                    ReadDecodedData();
                    //IOPortOGG = ReadDecodedData();
                    break;
                case 0x3a:  //PSG
                    WritePsgData();
                    break;
                case 0x80:  //WAIT
                case 0x81:
                case 0x82:
                case 0x83:
                case 0x84:
                case 0x85:
                case 0x86:
                case 0x87:
                    data_waitN = cmd - 0x80;
                    return;
                case 0x8d:  //WAIT
                    data_waitN = ReadDecodedData();
                    return;
                case 0x8e:  //loop
                    switch(loop_mode)
                    {
                        case LoopMode_One:
                            data_current_pos = ReadDecodedData();
                            data_current_pos += ((unsigned short)ReadDecodedData()) << 8;
                            SeekDecodedData(data_current_pos);
                            break;
                        case LoopMode_All:
                            music_notify = PlayerNotify_Next;
                            break;
                        case LoopMode_None:
                            data_current_pos = 0xffff;
                            music_current_stat = PlayerStatus_Stop;
                            return;
                    }
                    return;
                case 0x8f:  //end
                    data_current_pos = 0xffff;
                    music_current_stat = PlayerStatus_Stop;
                    music_notify = PlayerNotify_Next;
                    return;
                default:
                    WriteOpllData(cmd);
                    break;
            }
        }
    }
}

void PrintLoopMode()
{
    switch(loop_mode)
    {
        case LoopMode_All:
            PrintText("LOOP AL",25,22);
            break;
        case LoopMode_One:
            PrintText("LOOP 1 ",25,22);
            break;
        case LoopMode_None:
            PrintText("LOOP NO",25,22);
            break;
    }
}

static unsigned char music_last_stat = 0xff;

inline static void PrintCurrentStat()
{
    if(music_last_stat != music_current_stat)
    {
        switch(music_current_stat)
        {
            case PlayerStatus_Stop:
                PrintText("PLAY",25,19);
                break;
            case PlayerStatus_Play:
                PrintText("STOP",25,19);
                break;
        }
        music_last_stat = music_current_stat;
    }
}

void InitVGM()
{
    music_selected_no = 0;
    music_current_no = 0;

    music_last_stat = 0xff;
    music_current_stat = PlayerStatus_Stop;
    music_command = PlayerCommand_None;

    PrintText("cccccccccccccccccccccccccccccccc",0,13);
    PrintText(music_data[music_selected_no].title,0,14);
    PrintText("cccccccecccccccccccccccceccccccc",0,15);
    for(int i=0;i<8;i++)
        PrintText("d                d",7,16+i);

    // PrintChar('f',3,16);
    // PrintChar('g',3,18);

    PrintText("TIME",25,16);
    InitTime();
    PrintTime();

    PrintText("PLAY",25,19);
    PrintText(" 1 BTN",25,20);

    PrintLoopMode();
    PrintText(" 2 BTN",25,23);

    // PrintLoopMode();

}

static void drawLevel(struct OutputData *odp, char x)
{
    unsigned char tv = odp->volume;
    register unsigned char vol = (0xf - tv) >> 1;
    register unsigned char lvol = (0xf - odp->last_volume) >> 1;
    if(vol > lvol)
    {
        for(int y = lvol;y<=vol;y++)
        {
            const signed char tileNo = FONT_TILES_NO_E + 1;
            switch(y)
            {
                case 7:
                    SetTileatXY(x, 23-y, tileNo+2);
                    break;
                case 6:
                case 5:
                case 4:
                    SetTileatXY(x, 23-y, tileNo+1);
                    break;
                default:
                    SetTileatXY(x, 23-y, tileNo);
                    break;
            }
        }
    }else
    {
        for(int y = lvol;y>=vol;y--)
            SetTileatXY(x, 23-y, 0);
    }
    odp->last_volume = tv;
    if(tv < 0xf)
        odp->volume = tv+1;
}

void processPlayer(char vblank)
{
    if(vblank)
    {
        unsigned int key = SMS_getKeysPressed();
        if(music_notify == PlayerNotify_Next)
        {
            music_notify = PlayerNotify_None;
            music_selected_no++;
            if(music_selected_no > 1 + sizeof(music_data)/sizeof(music_data))
                music_selected_no = 0;
            PrintText(music_data[music_selected_no].title,0,14);
            music_current_no = music_selected_no;
            music_command = PlayerCommand_Play;
        }
        switch(key)
        {
            case PORT_A_KEY_LEFT:
                music_selected_no--;
                if(music_selected_no < 0)
                    music_selected_no = 1 + sizeof(music_data)/sizeof(music_data);
                PrintText(music_data[music_selected_no].title,0,14);
                break;
            case PORT_A_KEY_RIGHT:
                music_selected_no++;
                if(music_selected_no > 1 + sizeof(music_data)/sizeof(music_data))
                    music_selected_no = 0;
                PrintText(music_data[music_selected_no].title,0,14);
                break;
            case PORT_A_KEY_1:
                switch (music_current_stat)
                {
                    case PlayerStatus_Stop:
                        music_current_no = music_selected_no;
                        music_command = PlayerCommand_Play;
                        break;
                    case PlayerStatus_Play:
                        if(music_current_no == music_selected_no)
                            music_command = PlayerCommand_Stop;
                        else
                        {
                            music_current_no = music_selected_no;
                            music_command = PlayerCommand_Play;
                        }
                        break;
                }
                break;
            case PORT_A_KEY_2:
                switch(loop_mode)
                {
                    case LoopMode_All:
                        loop_mode = LoopMode_One;
                        break;
                    case LoopMode_One:
                        loop_mode = LoopMode_None;
                        break;
                    case LoopMode_None:
                        loop_mode = LoopMode_All;
                        break;
                }
                PrintLoopMode();
                break;
        }

        PrintTime();
        PrintCurrentStat();

        for(char i=0;i<6;i++)
            drawLevel(output_data_opll+i,8+i);
        for(char i=0;i<4;i++)
            drawLevel(output_data_psg+i,14+i);
        for(char i=6;i<12;i++)
            drawLevel(output_data_opll+i,12+i);
    }
}
