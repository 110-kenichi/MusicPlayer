#include "PSGlib.h"
#include "main.h"
#include "sel_tile.h"

#pragma codeseg BANK_C3

// void NmiInterruptHandler() { __asm__("RST 0"); }
// unsigned int __at (0xC000) chksum;

//                      0         1,       2, 3,        4,               5, 6,
//                      7,       8,              9,             10, 0        UP,
//                      DOWN,        LEFT,              UL,              DL, 0,
//                      RIGHT,             UR,             RD,
const short dirX_player[16] = {0,
                               00000000,
                               0000000,
                               0,
                               -1 * 256,
                               -1 * 256 * 0.85,
                               -1 * 256 * 0.85,
                               0,
                               1 * 256,
                               01 * 256 * 0.85,
                               1 * 256 * 0.85,
                               0,
                               0,
                               0,
                               0,
                               0};
const short dirY_player[16] = {0,
                               -1 * 256,
                               1 * 256,
                               0,
                               00000000,
                               -1 * 256 * 0.85,
                               01 * 256 * 0.85,
                               0,
                               0000000,
                               -1 * 256 * 0.85,
                               1 * 256 * 0.85,
                               0,
                               0,
                               0,
                               0,
                               0};

typedef enum CharacterTypeEnum {
  None = 0,
  Ct_Player = 1,   // 1 sprites 0
  Ct_Player2 = 5,  // 1 sprites 0
  Ct_Shot = 2,     // 2 sprites 1 2
  Ct_Option = 3,   // 1 sprites 3
  Ct_OptShot = 4,  // 18 sprites 13
} CharacterType;

void moveCharsSel() {
  SMS_initSprites();
  for (int i = 0; i < 16; i++) {
    Character *c = &Characters[i];
    switch (c->type) {
      case Ct_Player2: {
        Character *pc = &Characters[0];

        int px = pc->x.Body.Integer;
        int py = pc->y.Body.Integer;
        int *sp = &((int *)sel_sp_map_bin)[1];
        AddSprite(px + 8 - 20, py, *sp++);
        AddSprite(px + 16 - 20, py, *sp++);
        AddSprite(px + 24 - 20, py, *sp++);

        break;
      }
      case Ct_Player: {
        switch (c->status) {
          case 0x1:  // normal
          {
            int key = SMS_getKeysStatus();
            if (c->status >= 1) {
              // Get pressed key num
              int keyd = key & 0xf;
              // Calc position by Fixed FP16
              c->dx.Word = dirX_player[keyd] << 1;
              c->dy.Word = dirY_player[keyd] << 1;
            }
            // Move character position
            AddF24_s16(&c->x, c->dx.Word);
            AddF24_s16(&c->y, c->dy.Word);
            if (c->x.Body.Integer < 16 || c->x.Body.Integer > 255)
              SubF24_s16(&c->x, c->dx.Word);
            if (c->y.Body.Integer < 0 || c->y.Body.Integer > 192 - 40)
              SubF24_s16(&c->y, c->dy.Word);
            int x = c->x.Body.Integer;
            int y = c->y.Body.Integer;
            y += 16;
            int *sp = &((int *)sel_sp_map_bin)[32];
            AddSprite(x + 0 - 20, y, *sp++);
            AddSprite(x + 8 - 20, y, *sp++);
            AddSprite(x + 16 - 20, y, *sp++);
            AddSprite(x + 24 - 20, y, *sp++);
            AddSprite(x + 32 - 20, y, *sp++);
            y += 16;
            sp = &((int *)sel_sp_map_bin)[64];
            AddSprite(x + 0 - 20, y, *sp++);
            AddSprite(x + 8 - 20, y, *sp++);
            AddSprite(x + 16 - 20, y, *sp++);
            AddSprite(x + 24 - 20, y, *sp++);
            AddSprite(x + 32 - 20, y, *sp++);
            c->counter++;

            key = SMS_getKeysHeld();
            if (c->status == 1 && (c->counter & 1) == 0) {
              if ((key & PORT_A_KEY_1) == PORT_A_KEY_1) {
                for (int i = 4; i < 3 + 4; i++) {
                  Character *bc = &Characters[i];
                  if (bc->status == 0) {
                    bc->type = Ct_Shot;
                    bc->status = 1;
                    bc->x = c->x;
                    SubF24_s16(&bc->x, 0x300);
                    bc->y = c->y;
                    bc->dy.Word = -0x2000;
                    // FIRESFX(bomb_psg_xev, 0, SFX_CHANNEL2, PRIORITY_HIGH);
                    break;
                  }
                }
                for (int i = 4 + 4; i < 3 + 4 + 4; i++) {
                  Character *bc = &Characters[i];
                  if (bc->status == 0) {
                    Character *oc = &Characters[1];
                    bc->type = Ct_OptShot;
                    bc->status = 1;
                    bc->x = oc->x;
                    SubF24_s16(&bc->x, 0x400);
                    bc->y = oc->y;
                    bc->dy.Word = -0x2000;
                    bc->counter = 0;
                    // FIRESFX(bomb_psg_xev, 0, SFX_CHANNEL2, PRIORITY_HIGH);
                    break;
                  }
                }
                for (int i = 4 + 4 + 4; i < 3 + 4 + 4 + 4; i++) {
                  Character *bc = &Characters[i];
                  if (bc->status == 0) {
                    Character *oc = &Characters[2];
                    bc->type = Ct_OptShot;
                    bc->status = 1;
                    bc->x = oc->x;
                    SubF24_s16(&bc->x, 0x400);
                    bc->y = oc->y;
                    bc->dy.Word = -0x2000;
                    bc->counter = 1;
                    // FIRESFX(bomb_psg_xev, 0, SFX_CHANNEL2, PRIORITY_HIGH);
                    break;
                  }
                }
              }
            } else if (c->status == 2) {
              c->status = 1;
            }

            break;
          }
        }
        break;
      }
      case Ct_Shot: {
        if (c->status == 1) {
          AddF24_s16(&c->y, c->dy.Word);
          if (c->y.Body.Integer < -32)
            c->status = 0;
          else {
            AddSprite(c->x.Body.Integer, c->y.Body.Integer,
                      ((int *)sel_sp_map_bin)[8]);
            AddSprite(c->x.Body.Integer, c->y.Body.Integer + 16,
                      ((int *)sel_sp_map_bin)[40]);
          }
        }
        break;
      }
      case Ct_OptShot: {
        if (c->status == 1) {
          AddF24_s16(&c->y, c->dy.Word);
          if (c->y.Body.Integer < -16)
            c->status = 0;
          else {
            AddSprite(c->x.Body.Integer, c->y.Body.Integer,
                      ((int *)sel_sp_map_bin)[9]);
          }
        }
        break;
      }
      case Ct_Option: {
        if ((c->counter & 2) == 0) {
          Character *pc = &Characters[0];
          FixedF24 fx;
          fx = pc->x;
          FixedF24 fy;
          fy = pc->y;
          int a = c->counter;
          short cos = SIN_TABLE[(127 - a + 32) & 0x7f].Word;
          short sin = SIN_TABLE[(127 - a + 0) & 0x7f].Word;
          short wy = (cos * 40) >> 1;
          short wx = sin * 40;
          AddF24_s16(&fx, wx);
          AddF24_s16(&fy, wy);
          c->x = fx;
          c->y = fy;
          c->counter += 2;
          c->counter &= 0x7f;

          int x = fx.Body.Integer;
          int y = fy.Body.Integer;
          AddSprite(x - 4, y + 8, ((int *)sel_sp_map_bin)[5]);
          AddSprite(x + 4, y + 8, ((int *)sel_sp_map_bin)[6]);
          AddSprite(x - 4, y + 24, ((int *)sel_sp_map_bin)[37]);
          AddSprite(x + 4, y + 24, ((int *)sel_sp_map_bin)[38]);
        } else {
          int x = c->x.Body.Integer;
          int y = c->y.Body.Integer;
          AddSprite(x - 4, y + 8, ((int *)sel_sp_map_bin)[5]);
          AddSprite(x + 4, y + 8, ((int *)sel_sp_map_bin)[6]);
          AddSprite(x - 4, y + 24, ((int *)sel_sp_map_bin)[37]);
          AddSprite(x + 4, y + 24, ((int *)sel_sp_map_bin)[38]);
        }
        c->counter++;
        break;
      }
    }
  }
}

void processSel(char vblank) {
  if (vblank) {
    switch (PhaseCounter) {
      case 0: {
        DisableVDPProcessing = true;
        SMS_displayOff();
        InitGameVars();
        SMS_VDPturnOnFeature(VDPFEATURE_SHIFTSPRITES);
        SMS_VDPturnOnFeature(VDPFEATURE_HIDEFIRSTCOL);
        SMS_VDPturnOnFeature(VDPFEATURE_USETALLSPRITES);

        SMS_loadPSGaidencompressedTiles(sel_bg_tile_psgcompr, 0);
        SMS_loadTileMapArea(16, 0, sel_bg_map_bin, 16, 24);

        SMS_loadPSGaidencompressedTiles(sel_sp_tile_psgcompr, SP_TILES_NO_S);

        // SMS_setNmiInterruptHandler(NmiInterruptHandler);

        DisableVDPProcessing = false;
        PhaseCounter++;
        ScreenX = 0 - 6;

        Characters[0].type = Ct_Player;
        Characters[0].x.Body.Integer = 64;
        Characters[0].y.Body.Integer = 127;
        Characters[0].dx.Word = 0x0000;
        Characters[0].dy.Word = 0x0000;
        Characters[0].dir = 0;
        Characters[0].status = 0x0001;

        Characters[1].type = Ct_Option;
        Characters[1].x.Body.Integer = 20;
        Characters[1].y.Body.Integer = 20;
        Characters[1].dx.Word = 0x0000;
        Characters[1].dy.Word = 0x0000;
        Characters[1].dir = 0;
        Characters[1].status = 0x0001;
        Characters[1].counter = 0;

        Characters[2].type = Ct_Option;
        Characters[2].x.Body.Integer = 20;
        Characters[2].y.Body.Integer = 20;
        Characters[2].dx.Word = 0x0000;
        Characters[2].dy.Word = 0x0000;
        Characters[2].dir = 0;
        Characters[2].status = 0x0001;
        Characters[2].counter = 66;

        Characters[3].type = Ct_Player2;
        Characters[3].x.Body.Integer = 64;
        Characters[3].y.Body.Integer = 127;
        Characters[3].dx.Word = 0x0000;
        Characters[3].dy.Word = 0x0000;
        Characters[3].dir = 0;
        Characters[3].status = 0x0001;

        SMS_displayOn();
        break;
      }
      case 1: {
        FadeInPalette(PhaseLocalCounter, sel_bg_pal_bin, sel_bg_pal_bin_size,
                      0);
        FadeInPalette(PhaseLocalCounter, sel_sp_pal_bin, sel_sp_pal_bin_size,
                      1);
        PhaseLocalCounter++;
        ScreenX += 1;
        if (PhaseLocalCounter == 7) {
          PhaseCounter++;
          PhaseLocalCounter = 0;
        }
        break;
      }
      case 2: {
        if (SMS_getKeysPressed() == PORT_A_KEY_2) {
          PhaseLocalCounter = 0;
          PhaseCounter++;
          break;
        }

        break;
      }
      case 3: {
        if (PhaseLocalCounter > 6) {
          PSGStop();
          GamePhase = G_PHASE_PLAYER;
        } else {
          FadeOutPalette(PhaseLocalCounter, sel_bg_pal_bin, sel_bg_pal_bin_size,
                         0);
        }
        PhaseLocalCounter++;
        break;
      }
    }
  } else {
    switch (PhaseCounter) {
      case 2: {
        moveCharsSel();
        break;
      }
    }
  }
}
