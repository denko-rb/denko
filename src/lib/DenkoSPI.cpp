#include "Denko.h"

//
// Functions for listeners shared between hardware and bit bang SPI.
//
#if defined(DENKO_SPI) || defined(DENKO_SPI_BB)
// CMD = 28
// Send a number for a select pin to remove a SPI listener.
void Denko::spiRemoveListener(){
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].select == pin) {
      spiListeners[i].enabled = 0;
    }
  }
}

// Gets called by Denko::reset to clear all listeners.
void Denko::spiClearListeners(){
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) {
    spiListeners[i].enabled = 0;
  }
}

void Denko::spiUpdateListeners(){
  for (byte i = 0;  i < SPI_LISTENER_COUNT;  i++){
    switch(spiListeners[i].enabled) {
      case 1: spiReadListener(i); break;
      #ifdef DENKO_SPI_BB
        case 2: spiBBreadListener(i); break;
      #endif
      default: break;
    }
  }
}
#endif

//
// Adds hardware SPI support if DENKO_SPI defined in DenkoDefines.h.
//
#ifdef DENKO_SPI
#include <SPI.h>
// Convenience wrapper for SPI.begin
void Denko::spiBegin(byte settings, uint32_t clockRate) {
  SPI.begin();

  // SPI mode is the lowest 2 bits of settings.
  byte mode = settings & 0B00000011;

  // Bit 7 of settings controls bit order. 0 = LSBFIRST, 1 = MSBFIRST.
  if (bitRead(settings, 7) == 0) {
    // True integer value for these macros vary by platform, so just do this.
    switch(mode){
      case 0: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE0)); break;
      case 1: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE1)); break;
      case 2: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE2)); break;
      case 3: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE3)); break;
    }
  } else {
    switch(mode){
      case 0: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE0)); break;
      case 1: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE1)); break;
      case 2: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE2)); break;
      case 3: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE3)); break;
    }
  }
}

// Convenience wrapper for SPI.end
void Denko::spiEnd() {
  SPI.endTransaction();
  // TXRX_SPI in defined for WiFi/Ethernet sketches on AVR chips.
  // In those cases, SPI.end() can't be called since the network hardware uses it.
  // ESP32 doesn't like when SPI.end is called either. Might be safe to never do it.
  #if !defined(TXRX_SPI) && defined(__AVR__)
    SPI.end();
  #endif
}

// CMD = 26
// Simultaneous read from and write to an SPI device.
//
// Request format for SPI 2-way transfers
// pin         = select pin
// val         = empty
// auxMsg[0]   = SPI settings
//   Bit 0..1  = SPI mode
//   Bit 2..5  = ** unused **
//   Bit 6     = Whether to toggle select pin (1), or not (0)
//   Bit 7     = Read and write bit order: MSBFIRST(1) or LSBFIRST(0)
// auxMsg[1]   = read length  (number of bytes)
// auxMsg[2]   = write length (number of bytes)
// auxMsg[3-6] = clock frequency (uint32_t as 4 bytes)
// auxMsg[7+]  = data (bytes) (write only)
//
void Denko::spiTransfer(uint32_t clockRate, uint8_t select, uint8_t settings, uint16_t rLength, uint16_t wLength, byte *data) {
  spiBegin(settings, clockRate);

  // Pull select low.
  if (bitRead(settings, 6) == 1) {
    pinMode(select, OUTPUT);
    digitalWrite(select, LOW);
  }

  // Go one byte at a time if reading bytes out.
  if (rLength > 0) {
    // Stream read bytes as if coming from select pin.
    stream->print(select);
    stream->print(':');

    for (uint16_t i=0; (i < rLength || i < wLength); i++) {
      byte b;

      if (i < wLength) {
        b = SPI.transfer(data[i]);
      } else {
        b = SPI.transfer(0x00);
      }

      if (i < rLength) {
        // Print read byte, then a comma or \n if it's the last read byte.
        stream->print(b);
        stream->print((i+1 == rLength) ? '\n' : ',');
      }
    }
  // Write the entire buffer at once if not reading.
  } else {
    SPI.transfer(data, wLength);
  }

  // Leave select high.
  if (bitRead(settings, 6) == 1) digitalWrite(select, HIGH);

  spiEnd();
}

// CMD = 27
// Start listening to a register with hardware SPI.
void Denko::spiAddListener() {
  // Do this since RP2040 crashes with reinterpet_cast of uint32_t.
  uint32_t  clockRate  = (uint32_t)auxMsg[3];
            clockRate |= (uint32_t)auxMsg[4] << 8;
            clockRate |= (uint32_t)auxMsg[5] << 16;
            clockRate |= (uint32_t)auxMsg[6] << 24;

  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].enabled == 0) {
      spiListeners[i].freq      = clockRate;
      spiListeners[i].select    = pin;                                              // Select pin
      spiListeners[i].settings  = auxMsg[0];                                        // Settings mask
      spiListeners[i].length    = (((uint16_t)auxMsg[3] & 0xF0) << 4) | auxMsg[1];  // Read length
      spiListeners[i].enabled   = 1;                                                // 1 sets this listener as Hardware SPI
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// Called by spiUpdateListeners to read an individual hardware SPI listener.
void Denko::spiReadListener(uint8_t i) {
  spiTransfer(spiListeners[i].freq,
              spiListeners[i].select,
              spiListeners[i].settings,
              spiListeners[i].length,
              0,                          // 0 bytes written to output
              &auxMsg[0]);                // Get "write" data from anywhere since not writing
}
#endif
