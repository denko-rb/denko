//
// This file adds to the Denko class only if DENKO_I2C is defined in Denko.h.
//
#include "Denko.h"
#ifdef DENKO_I2C

#include <Wire.h>

// Only start the I2C interface if not already started.
// Lazy initialization in case user wants to use I2C pins for something else.
void Denko::i2cBegin() {
  if (!i2cStarted) {
    Wire.begin();
    i2cStarted = true;
    i2cSetSpeed(0);
  }
}

// End the I2C interface.
// This is mostly used as a Reset in Denko::handshake.
void Denko::i2cEnd(){
  i2cSetSpeed(0);
  // ESP8266 core does not define Wire.end()
  #ifndef ESP8266
    Wire.end();
  #endif
  i2cStarted = false;
}

// Configurable I2C speed each time read or write is called.
void Denko::i2cSetSpeed(uint8_t code) {
  switch(code) {
    case 0:  Wire.setClock(100000);  break;
    case 1:  Wire.setClock(400000);  break;
    case 2:  Wire.setClock(1000000); break;
    case 3:  Wire.setClock(3400000); break;
    default: Wire.setClock(100000);  break;
  }
  i2cSpeed = code;

  // ESP32-H2 doesn't safely fallback if speed > 400kHz is chosen.
  #ifdef CONFIG_IDF_TARGET_ESP32H2
    if (i2cSpeed > 1) {
      i2cSpeed = 1;
      Wire.setClock(400000);
    }
  #endif
}

// CMD = 33
// Ask each address for a single byte to see if it exists on the bus.
void Denko::i2cSearch() {
  byte error;
  uint8_t addr;
  if (!i2cStarted) i2cBegin();
  i2cSetSpeed(0);
  stream->print("I2C0");

  // Only addresses from 0x08 to 0x77 are usable (8 to 127).
  for (addr = 0x08; addr < 0x78;  addr++) {
    Wire.beginTransmission(addr);
    error = Wire.endTransmission();
    if (error == 0){
      stream->print(':'); stream->print(addr);
    }
  }
  stream->print('\n');
}

//
// cmd         = 34
// pin         = <reseverd>
// val         = <reserved>
// auxMsg[0]   = I2C settings
//  Bits[7..2] = <reserved>
//  Bits[1..0] = Bitmask for I2C speed
// auxMsg[1]   = Device address in bits [6..0] + repeated start in bit 7
// auxMsg[2]   = Data length to write
// auxMsg[3]+  = Data
//
void Denko::i2cWrite() {
  // Get parameters from message.
  uint8_t speedMask  = auxMsg[0] & 0b00000011;
  uint8_t address    = auxMsg[1] & 0b01111111;
  uint8_t sendStop   = auxMsg[1] >> 7;
  uint8_t dataLength = auxMsg[2];

  // Limit to board's I2C buffer size.
  if (dataLength > DENKO_I2C_BUFFER_SIZE) dataLength = DENKO_I2C_BUFFER_SIZE;

  // Start and set speed.
  if (!i2cStarted)            i2cBegin();
  if (i2cSpeed != speedMask)  i2cSetSpeed(speedMask);

  Wire.beginTransmission(address);
  Wire.write(&auxMsg[3], dataLength);

  // No repeated start on ESP32.
  #if defined(ESP32)
    Wire.endTransmission();
  #else

    Wire.endTransmission(sendStop);
  #endif
}

//
// Read from an I2C device over a harwdare I2C interface.
//
// cmd         = 35
// pin         = <reseverd>
// val         = <reserved>
// auxMsg[0]   = I2C settings
//  Bits[7..2] = <reserved>
//  Bits[1..0] = Bitmask for I2C speed
// auxMsg[1]   = Device address in bits [6..0] + repeated start in bit 7
// auxMsg[2]   = Data length to read
// auxMsg[3]   = Register address length
// auxMsg[4]+  = Register address bytes if length > 0
//
void Denko::i2cRead() {
  // Get parameters from message.
  uint8_t speedMask  = auxMsg[0] & 0b00000011;
  uint8_t address    = auxMsg[1] & 0b01111111;
  uint8_t sendStop   = auxMsg[1] >> 7;
  uint8_t dataLength = auxMsg[2];

  // Limit to board's I2C buffer size.
  if (dataLength > DENKO_I2C_BUFFER_SIZE) dataLength = DENKO_I2C_BUFFER_SIZE;

  // Start and set speed.
  if (!i2cStarted)            i2cBegin();
  if (i2cSpeed != speedMask)  i2cSetSpeed(speedMask);

  // Optionally write up to a 4 byte register address before reading.
  if ((auxMsg[3] > 0) && (auxMsg[3] < 5)) {
    Wire.beginTransmission(address);
    Wire.write(&auxMsg[4], auxMsg[3]);
    Wire.endTransmission(sendStop);
  }

  // ESP32 crashes if requestFrom gets the 3rd arg.
  #if defined(ESP32)
    Wire.requestFrom(address, dataLength);
  #else
    Wire.requestFrom(address, dataLength, sendStop);
  #endif

  // Send data as if coming from a pin called "I2C0". Prefix with device adddress.
  // Fail silently if no bytes read / invalid device address.
  stream->print("I2C0:");
  stream->print(address); stream->print('-');
  while(Wire.available()){
    stream->print(Wire.read());
    stream->print(',');
  }
  stream->print('\n');

  // No repeated start on ESP32.
  #if defined(ESP32)
    Wire.endTransmission();
  #else
    Wire.endTransmission(sendStop);
  #endif
}
#endif
