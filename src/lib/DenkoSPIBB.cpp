//
// Adds SPI bitbang functionality to the Denko class if DENKO_SPI_BB defined in DenkoDefines.h.
//
#include "Denko.h"

#ifdef DENKO_SPI_BB
// CMD = 21
//
// Request format for bit banged SPI 2-way transfers
// pin         = select pin
// val         = empty
// auxMsg[0]   = SPI settings
//   Bit 0..1  = SPI mode
//   Bit 2..5  = ** unused **
//   Bit 6     = Whether to toggle select pin (1), or not (0)
//   Bit 7     = Read and write bit order: MSBFIRST(1) or LSBFIRST(0)
// auxMsg[1]   = read length  (number of bytes)
// auxMsg[2]   = write length (number of bytes)
// auxMsg[3]   = clock pin  (uint8)
// auxMsg[4]   = input pin  (uint8) - Set to 255 for one-way transfer.
// auxMsg[5]   = output pin (uint8) - Set to 255 for one-way transfer.
// auxMsg[6]   = ** unused **
// auxMsg[7+]  = data (bytes) (write only) - Start from 7 for parity with hardware SPI.
//
void Denko::spiBBtransfer (uint8_t clock, uint8_t input, uint8_t output, uint8_t select, uint8_t settings,
                           uint16_t rLength, uint16_t wLength, byte *data) {

  // Mode is the lowest 2 bits of settings.
  uint8_t mode = settings & 0b00000011;

  // Bit order is stored in the highest bit of settings.
  uint8_t bitOrder = bitRead(settings, 7);

  // Set modes for input and output pins.
  // Use a pin number of 255 to avoid touching either.
  if (output < 255) pinMode(output, OUTPUT);
  if (input < 255)  pinMode(input, INPUT);

  // Set idle state of clock pin based on SPI mode.
  pinMode(clock, OUTPUT);
  if ((mode == 0)||(mode == 1)) digitalWrite(clock, LOW);
  if ((mode == 2)||(mode == 3)) digitalWrite(clock, HIGH);

  // Stream read bytes as if coming from select pin.
  if (rLength > 0) {
    stream->print(select);
    stream->print(':');
  }

  // Pull select low, if needed.
  if (bitRead(settings, 6) == 1) {
    pinMode(select, OUTPUT);
    digitalWrite(select, LOW);
  }

  for (uint16_t i=0; (i < rLength || i < wLength); i++) {
    byte b;

    if (i < wLength) {
      b = spiBBtransferByte(clock, input, output, mode, bitOrder, data[i]);
    } else {
      b = spiBBtransferByte(clock, input, output, mode, bitOrder, 0x00);
    }

    if (i < rLength) {
      // Print read byte, then a comma or \n if it's the last read byte.
      stream->print(b);
      stream->print((i+1 == rLength) ? '\n' : ',');
    }
  }

  // Leave select high.
  if (bitRead(settings, 6) == 1) digitalWrite(select, HIGH);
}

//
// Used by spiBBtransfer to transfer a single byte at a time.
//
byte Denko::spiBBtransferByte(uint8_t clock, uint8_t input, uint8_t output, uint8_t mode, uint8_t bitOrder, byte data) {
  // Byte to return
  byte b = 0x00;

  // Track which of the 8 bits we're on.
  uint8_t bitPos;

  // Read and write 8 bits.
  for (int i=0; i<8; i++) {
    // Set which bit index is being read and written based on i and bit orders.
    if (bitOrder == 0) { bitPos = i; } else { bitPos = 7 - i; }

    // SPI MODE 0
    if (mode == 0){
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, HIGH);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
      digitalWrite(clock, LOW);
    }

    // SPI MODE 1
    if (mode == 1){
      digitalWrite(clock, HIGH);
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, LOW);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
    }

    // SPI MODE 2
    if (mode == 2){
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, LOW);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
      digitalWrite(clock, HIGH);
    }

    // SPI MODE 3
    if (mode == 3){
      digitalWrite(clock, LOW);
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, HIGH);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
    }
  }
  return b;
}

// CMD = 22
// Start listening to a register with bit bang SPI.
void Denko::spiBBaddListener() {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    // Overwrite the first disabled listener in the struct array.
    if (spiListeners[i].enabled == 0) {
      spiListeners[i].freq      = ((uint32_t)(auxMsg[4] << 8) | auxMsg[3]);         // SCK: [0..7], MOSI: [8..15] in freq's uint32.
      spiListeners[i].select    = pin;                                              // Select pin
      spiListeners[i].settings  = auxMsg[0];                                        // Settings mask
      spiListeners[i].length    = (((uint16_t)auxMsg[3] & 0xF0) << 4) | auxMsg[1];  // Read length
      spiListeners[i].enabled   = 2;                                                // 2 sets this listener as Bit-Bang
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// Called by spiUpdateListeners to read an individual bit bang SPI listener.
void Denko::spiBBreadListener(uint8_t i) {
  spiBBtransfer ((spiListeners[i].freq & 0xFF),         // SCK pin is bits [0..7] of freq's uint32
                ((spiListeners[i].freq >> 8) & 0xFF),   // MOSI pin is bits [8..15] of freq's uint32
                255,                                    // Disabled output pin
                spiListeners[i].select,                 // Select pin
                spiListeners[i].settings,
                spiListeners[i].length,                 // Read length
                0,                                      // 0 bytes written to output
                &auxMsg[0]);                            // Get "write" data from anywhere since not writing
}
#endif
