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
  stream->print(SDA);

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

// CMD = 34
// Write to an I2C device over a harwdare I2C interface.
//
// pin
//  bits 0..6 = Device address
//  bit  7    = Send stop condition. 0 = no, repeated start. 1 = yes.
//
// val
//  bits 0..4 = Data length. NOTE: maximum of 32. Anything more is ignored.
// 
// auxMsg[0]  = I2C settings. Just speed selection for now.
//
// auxMsg[1]+ = data
//
void Denko::i2cWrite() {
  // Get parameters from message.
  uint8_t address     =  (uint8_t)pin & 0b01111111;
  uint8_t dataLength  =  (uint8_t)val;

  // Limit to 32 bytes.
  if (dataLength > DENKO_I2C_BUFFER_SIZE) dataLength = DENKO_I2C_BUFFER_SIZE;

  if (!i2cStarted)            i2cBegin();
  if (i2cSpeed != auxMsg[0])  i2cSetSpeed(auxMsg[0]);

  Wire.beginTransmission(address);
  Wire.write(&auxMsg[1], dataLength);

  // No repeated start on ESP32.
  #if defined(ESP32)
    Wire.endTransmission();
  #else
    uint8_t sendStop = (uint8_t)pin >> 7;
    Wire.endTransmission(sendStop);
  #endif
}

// CMD = 35
// Read from an I2C device over a harwdare I2C interface.
//
// pin
//  bits 0..6 = Device address
//  bit  7    = Send stop condition. 0 = no, repeated start. 1 = yes.
//
// val
//  bits 0..4 = Data length. NOTE: maximum of 32. Anything more is ignored.
//
// auxMsg[0]  = I2C settings. Just speed selection for now.
//
// auxMsg[1]  = If > 0, write a register address of that many bytes before reading.
// auxMsg[2]+ = Register address bytes in order.
//
void Denko::i2cRead() {
  // Get parameters from message.
  uint8_t address         = (uint8_t)pin & 0b01111111;
  uint8_t sendStop        = (uint8_t)pin >> 7;
  uint8_t dataLength      = (uint8_t)val;

  // Limit to 32 bytes.
  if (dataLength > DENKO_I2C_BUFFER_SIZE) dataLength = DENKO_I2C_BUFFER_SIZE;

  if (!i2cStarted)            i2cBegin();
  if (i2cSpeed != auxMsg[0])  i2cSetSpeed(auxMsg[0]);
  
  // Optionally write up to a 4 byte register address before reading.
  if ((auxMsg[1] > 0) && (auxMsg[1] < 5)) {
    Wire.beginTransmission(address);
    Wire.write(&auxMsg[2], auxMsg[1]);
    Wire.endTransmission(sendStop);
  }
  
  // ESP32 crashes if requestFrom gets the 3rd arg.
  #if defined(ESP32)  
    Wire.requestFrom(address, dataLength);
  #else
    Wire.requestFrom(address, dataLength, sendStop);
  #endif
  
  // Send data as if coming from SDA pin. Prefix with device adddress.
  // Fail silently if no bytes read / invalid device address.
  stream->print(SDA); stream->print(':');
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
