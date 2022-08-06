#pragma codeseg BANK_C1

#include "logo_tile.h"
#include "main.h"

void processLogo(char vblank) /*__banked*/ {
  if (SMS_getKeysPressed() == PORT_A_KEY_2) {
    PhaseLocalCounter = 0;
    PhaseCounter = 12;
  }

  if (vblank) {
    switch (PhaseCounter) {
      case 0: {
        DisableVDPProcessing = true;
        SMS_displayOff();
        InitGameVars();
        InitFont();
        SMS_VDPturnOffFeature(VDPFEATURE_SHIFTSPRITES);
        SMS_VDPturnOffFeature(VDPFEATURE_HIDEFIRSTCOL);

        SMS_loadPSGaidencompressedTiles(logo_tile_psgcompr, BG_TILES_NO_S);
        SMS_loadTileMapArea(7, 3, logo_map_bin, 18, 12);
        for (int i = 0; i < 16; i++)
          SetSpritePaletteColor(i, logo_pal_bin[i]);

        PhaseCounter++;
        PhaseLocalCounter = 0;

        SMS_displayOn();
        DisableVDPProcessing = false;
        break;
      }
      case 1: {
        //FadeInPalette(PhaseLocalCounter, logo_pal_bin, logo_pal_bin_size, 0);
        PhaseLocalCounter++;
        if (PhaseLocalCounter == 7) {
          PhaseCounter++;
          PhaseLocalCounter = 0;
        }
        break;
      }
      case 2: {
        //DISABLE_INTERRUPTS;
        //PcmInit();
        //PlayPcmSound(&Wave_pcmenc);
        //ENABLE_INTERRUPTS;

        PhaseLocalCounter++;
        if (PhaseLocalCounter == 30) {
          PhaseCounter++;
          PhaseLocalCounter = 0;
        }

        break;
      }
      case 3: {
        //FadeOutPalette(PhaseLocalCounter, logo_bg_pal_bin, logo_bg_pal_bin_size, 0);
        PhaseLocalCounter++;
        if (PhaseLocalCounter == 7) {
          PhaseCounter++;
          PhaseLocalCounter = 0;
        }
        break;
      }
      case 4: {
        GamePhase = G_PHASE_PLAYER;
        break;
      }
    }
  }
}
