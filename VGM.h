
__sfr __at 0x06 IOPortOGG;

__sfr __at 0x7F IOPortOPSG;

__sfr __at 0xF0 IOPortOPLL1;
__sfr __at 0xF1 IOPortOPLL2;

#define OUT_BUFFER_SIZE 4

#define SPLIT_SIZE (16384 - 512)

extern const unsigned short uncle_op_0_Size;
extern const unsigned char uncle_op_0_Data[];

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

enum PlayerNotify
{
    PlayerNotify_None = 0,
    PlayerNotify_Next = 1,
};

enum LoopMode
{
    LoopMode_All = 0,
    LoopMode_One = 1,
    LoopMode_None = 2,
};

struct MusicData
{
    unsigned char bank_no;
    unsigned char loop_bank_no;
    unsigned char loop_bank_ofset;
    unsigned char compressed;
    unsigned short *size;
    unsigned char *data;
    unsigned char *title;
};

struct OutputData
{
    unsigned char keyon;
    unsigned char volume;
    unsigned char last_volume;
    unsigned char key;
    unsigned char last_key;
};

struct ElapseData
{
    unsigned char sec0;
    unsigned char sec1;
    unsigned char min0;
    unsigned char min1;
};