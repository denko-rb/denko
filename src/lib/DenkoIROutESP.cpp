//
// Denko IR output for the ESP8266 and ESP32.
// Depends on: https://github.com/crankyoldgit/IRremoteESP8266
// DENKO_IR_OUT must be defeind in DenkoDefines.h
//
#include "Denko.h"
#if defined(DENKO_IR_OUT) && (defined(ESP8266) || defined(ESP32))

#include <IRremoteESP8266.h>
#include <IRsend.h>

// CMD = 16
// Send an infrared signal.
void Denko::irSend(){
  // Byte 1+ of auxMsg is already little-endian uint16 pulses.
  uint16_t *pulseArray = reinterpret_cast<uint16_t *>(auxMsg + 1);
  
  // Can work on any pin.
  IRsend infraredOut(pin);
  infraredOut.begin();
  
  // auxMsg[0] is how many pulses were packed.
  // val is frequency
  infraredOut.sendRaw(pulseArray, auxMsg[0], val);
}
#endif
