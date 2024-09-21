//
// This file adds to the Denko class only if DENKO_IR_OUT is defined in Denko.h.
//
#include "Denko.h"
#if defined(DENKO_IR_OUT)

// Save memory by disabling receiver.
#undef RAW_BUFFER_LENGTH
#define RAW_BUFFER_LENGTH 0
#define DISABLE_CODE_FOR_RECEIVER

// Save more memory.
#define IR_REMOTE_DISABLE_RECEIVE_COMPLETE_CALLBACK true
#define EXCLUDE_UNIVERSAL_PROTOCOLS
#define EXCLUDE_EXOTIC_PROTOCOLS
#define NO_LED_FEEDBACK_CODE

#include <IRremote.hpp>

// CMD = 16
// Send an infrared signal.
void Denko::irSend(){
  // Change send pin per call. Must be PWM capable.
  IrSender.setSendPin(pin);

  // Byte 2+ of auxMsg is already little-endian uint16 pulses.
  //
  // WARNING: This offset must always be an even number, for aligned
  // memory access on the ESP8266, or it breaks.
  uint16_t *pulseArray = reinterpret_cast<uint16_t *>(auxMsg + 2);

  // auxMsg[0..1] contains number of pulses, also uint16.
  uint16_t length = *reinterpret_cast<uint16_t *>(auxMsg);  

  // Val contains frequency
  IrSender.sendRaw(pulseArray, length, val);
}
#endif
