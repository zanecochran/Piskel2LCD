// Piskel2LCD Example
// Zane Cochran
// Hardware: Teensy 4.0 and ILI9341 LCD Screen
// Libraries: Modified ILI9341_t3n.h Library (Adds RGB Sprite Support)

// Screen Libraries
#include "SPI.h"
#include "ILI9341_t3n.h"

#define TFT_DC  9
#define TFT_CS  10
#define TFT_RST 8

DMAMEM uint16_t fb1[320 * 240];
ILI9341_t3n tft = ILI9341_t3n(TFT_CS, TFT_DC, TFT_RST);

// Graphics
#include "colors_MASK.h"
#include "colors_PIX.h"

int whichTile = 0;
int numTiles = 23;
int tileSize = 32;

// Timing Libraries
#include <Metro.h> //Include Metro library
Metro screenRefresh = Metro(40); 
Metro frameRate = Metro(1000); 
int frameCounter = 0;

void setup() {
  Serial.begin(9600);
  tft.begin();
  tft.setRotation(1);
  
  tft.setFrameBuffer(fb1);
  tft.useFrameBuffer(1);

  tft.fillScreen(ILI9341_BLACK);
}

void loop() {
  tft.fillScreen(ILI9341_BLACK);
  tft.drawRGBBitmap(40, 40, colors_PIX[whichTile], colors_MASK[whichTile], tileSize, tileSize);

  if(screenRefresh.check()){tft.updateScreen(); whichTile = (whichTile + 1) % numTiles;}
  if(frameRate.check()){Serial.println(frameCounter); frameCounter = 0;}

  frameCounter++;
}
