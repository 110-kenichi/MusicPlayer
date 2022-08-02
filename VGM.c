#include "heatshrink_decoder.h"
#include "Font.h"
#include "main.h"

#pragma codeseg BANK_C2

__sfr __at 0x06 IOPortOGG;

__sfr __at 0x7F IOPortOPSG;

__sfr __at 0xF0 IOPortOPLL1;
__sfr __at 0xF1 IOPortOPLL2;

extern const unsigned short Fantasy_Zone___12___Last_Boss_Size;
extern const unsigned char Fantasy_Zone___12___Last_Boss_Data[];

extern const unsigned short Out_Run__FM____01___Magical_Sound_Shower_Size;
extern const unsigned char Out_Run__FM____01___Magical_Sound_Shower_Data[];

extern const unsigned short Fantasy_Zone_II__FM____Fuwareak_Size;
extern const unsigned char Fantasy_Zone_II__FM____Fuwareak_Data[];

enum PlayerCommand
{
    PlayerCommand_None = 0,
    PlayerCommand_Play = 1,
    PlayerCommand_Stop = 2,
};

enum PlayerStatus
{
    PlayerStatus_Stop = 0,
    PlayerStatus_Play = 1,
};

struct MusicData
{
    unsigned char bank_no;
    unsigned char compressed;
    unsigned short *size;
    unsigned char *data;
    unsigned char *title;
};

struct MusicData music_data[] =
{
    {DATA_BANK_S + 1, 0, &Fantasy_Zone___12___Last_Boss_Size, Fantasy_Zone___12___Last_Boss_Data, "FANTASY ZONE - LAST BOSS"},
    {DATA_BANK_S + 2, 1, &Out_Run__FM____01___Magical_Sound_Shower_Size, Out_Run__FM____01___Magical_Sound_Shower_Data, "OUTRUN - MAGICAL SOUND SHOWER"},
    {DATA_BANK_S + 3, 1, &Fantasy_Zone_II__FM____Fuwareak_Size, Fantasy_Zone_II__FM____Fuwareak_Data, "FANTASY ZONE II - FUWAREAK"},
};

static short music_selected_no;
static short music_current_no;

static unsigned char music_last_stat = 0xff;
static unsigned char music_current_stat = 0;
static unsigned char music_command = PlayerCommand_None;

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

#define OUT_BUFFER_SIZE 4

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
}

static void VGMSoundOff()
{
    IOPortOPSG = 0b10011111;
    IOPortOPSG = 0b10111111;
    IOPortOPSG = 0b11011111;
    IOPortOPSG = 0b11111111;

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

            music_command = PlayerCommand_None;
            music_current_stat = PlayerStatus_Stop;
            break;
        }
        case PlayerCommand_Play:
        {
            VGMSoundOff();
            InitDecoder();

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
    {
        music_current_stat = PlayerStatus_Stop;
        return;
    }
    if(data_waitN)
    {
        data_waitN--;
        return;
    }

    while(1){
        unsigned char cmd = PeekDecodedData();
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
                    IOPortOPSG = ReadDecodedData();
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
                    data_current_pos = ReadDecodedData();
                    data_current_pos += ((unsigned short)ReadDecodedData()) << 8;
                    SeekDecodedData(data_current_pos);
                    return;
                case 0x8f:  //end
                    data_current_pos = 0xffff;
                    music_current_stat = 0;
                    return;
                default:
                    IOPortOPLL1 = cmd;
                    IOPortOPLL2 = ReadDecodedData();
                    break;
            }
        }
    }
}


void InitVGM()
{
    music_selected_no = 0;
    music_current_no = 0;

    music_last_stat = PlayerStatus_Stop;
    music_current_stat = PlayerStatus_Stop;
    music_command = PlayerCommand_None;

    PrintText(music_data[music_selected_no].title,0,0);
}

void processPlayer(char vblank)
{
    if(vblank)
    {
        switch(SMS_getKeysPressed())
        {
            case PORT_A_KEY_LEFT:
                music_selected_no--;
                if(music_selected_no < 0)
                    music_selected_no = 1 + sizeof(music_data)/sizeof(music_data);
                PrintText(music_data[music_selected_no].title,0,0);
                break;
            case PORT_A_KEY_RIGHT:
                music_selected_no++;
                if(music_selected_no > 1 + sizeof(music_data)/sizeof(music_data))
                    music_selected_no = 0;
                PrintText(music_data[music_selected_no].title,0,0);
                break;
            case PORT_A_KEY_2:
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
        }
    }
}
