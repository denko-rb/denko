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
  #ifdef ESP32
    #include <esp.c>
  #endif

  #ifdef ARDUINO_ARCH_RP2040
    Adafruit_NeoPixel ledArray;
  #endif
#endif

//
// CMD = 19
// Write data to a WS2812 LED array. Will generalize to other types later.
//
// pin          = Microcontroller pin connected to Data In pin of the LED array.
// val          = Number of raw pixel data bytes to expect. Max 9999.
// auxMsg[0..3] = ALWAYS ZERO or ESP32 can crash if pixel bytes have certain low values. Very confusing.
// auxMsg[4..7] = Reserved for future settings.
// auxMsg[8+]   = Raw pixel data, already in correct byte order (GRB, RGB, etc.).
//
#define WS2812_DATA_OFFSET 8
//
void Denko::showLEDArray() {
  // Avoid memcpy on ESP32 by calling espShow() directly.
  #ifdef ESP32
    espShow(pin, &auxMsg[WS2812_DATA_OFFSET], val, true);

  // Pre-init instance (one PIO) on Pi Pico.
  #elif defined(ARDUINO_ARCH_RP2040)
    ledArray.setPin(pin);
    ledArray.updateLength(val);
    memcpy(ledArray.getPixels(), &auxMsg[WS2812_DATA_OFFSET], val);
    ledArray.show();

  // Reinit and memcpy for everything else.
  #else
    // Setup a new LED array object.
    Adafruit_NeoPixel ledArray(val, pin, NEO_GRB + NEO_KHZ800);
    ledArray.begin();

    // Copy LED data into the pixel buffer.
    memcpy(ledArray.getPixels(), &auxMsg[WS2812_DATA_OFFSET], val);

    // Let the line stay low for about 6 bytes worth of data.
    // Prevents first pixel green being stuck on.
    microDelay(60);

    // Write the pixel buffer to the array.
    ledArray.show();
  #endif

  // Tell the computer to resume sending data.
  sendReady();
}
#endif
