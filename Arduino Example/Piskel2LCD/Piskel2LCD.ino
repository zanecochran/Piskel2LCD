// Piskel2LCD Example
// Zane Cochran
// Hardware: Teensy 4.0 and ILI9341 LCD Screen
// Libraries: Modified ILI9341_t3n.h Library (Adds RGB Sprite Support) and Metro Library

// Screen Libraries
#include "SPI.h"
#include "ILI9341_t3n.h"

// Hook Up Teensy to LCD Screen using Table here: https://www.pjrc.com/store/display_ili9341.html 
#define TFT_DC  9
#define TFT_CS  10
#define TFT_RST 8   // This is modified from Table

DMAMEM uint16_t fb1[320 * 240];
ILI9341_t3n tft = ILI9341_t3n(TFT_CS, TFT_DC, TFT_RST);

int screenW = 320;  // 2.2" ILI9341 LCD Screen
int screenH = 240;  // 2.2" ILI9341 LCD Screen

// Sprite Graphics
#include "colors_MASK.h"  // Import Colors Animation Transparency Mask
#include "colors_PIX.h"   // Import Colors Animation Pixels

int whichSprite = 0;      // Keep Track of Sprite Animation Frame

// Timing Libraries
#include <Metro.h> //Include Metro library

Metro spriteRefresh = Metro(100);   // Update Sprite every 100ms
Metro screenRefresh = Metro(40);    // Update Screen every 40ms (~23 FPS)
Metro frameRate = Metro(1000);      // Update Framerate Counter every 1000ms 

int frameCounter = 0;               // Keep Track of Framerate

void setup() {
  Serial.begin(9600);               // Start Serial (debugging only)
  tft.begin();                      // Connect to LCD Screen
  tft.setRotation(1);               // Rotate Screen 90 Degrees
  
  tft.setFrameBuffer(fb1);          // Initialize Frame Buffer
  tft.useFrameBuffer(1);            // Use Frame Buffer

  tft.fillScreen(ILI9341_BLACK);    // Clear Screen
}

void loop() {
  
  tft.fillScreen(ILI9341_BLACK);    // Clear Screen

  // Tile Animation Across Entire Screen
  for (int x = 0; x < screenW / colors_W; x++){
    for (int y = 0; y < screenH / colors_H; y++){
      tft.drawRGBBitmap(x * colors_W, y * colors_H, colors_PIX[whichSprite], colors_MASK[whichSprite], colors_W, colors_H);
    }
  }
  
  if(spriteRefresh.check()){whichSprite = (whichSprite + 1) % colors_COUNT;}  // Update Animation Frames
  if(screenRefresh.check()){tft.updateScreen();}                              // Update Screen
  if(frameRate.check()){Serial.println(frameCounter); frameCounter = 0;}      // Update Frame Counter
  frameCounter++;                                                             // Increment Frame Counter
  
}
