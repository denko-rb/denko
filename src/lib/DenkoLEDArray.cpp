//
// Write addressable LEDs using standard Arduino libraries.
//
#include "Denko.h"
#ifdef DENKO_LED_ARRAY

//
// WS2812 / NeoPixel support using Adafruit library from:
// https://github.com/adafruit/Adafruit_NeoPixel
//
#ifdef DENKO_LED_WS2812
  #include <Adafruit_NeoPixel.h>
#endif

//
// CMD = 19
// Write data to a WS2812 LED array. Will generalize to other types later.
//
// pin          = Microcontroller pin connected to Data In pin of the LED array.
// val          = Number of raw pixel data bytes to expect. Max 9999.
// auxMsg[0..3] = Reserved for future settings.
// auxMsg[4+]   = Raw pixel data, already in correct byte order (GRB, RGB, etc.).
//
void Denko::showLEDArray() {
  // Setup a new LED array object.
  Adafruit_NeoPixel ledArray(val, pin, NEO_GRB + NEO_KHZ800);
  ledArray.begin();

  // Copy LED data into the pixel buffer.
  memcpy(ledArray.getPixels(), &auxMsg[4], val);

  // Write the pixel buffer to the array.
  ledArray.show();

  // Tell the computer to resume sending data.
  sendReady();
}
#endif
