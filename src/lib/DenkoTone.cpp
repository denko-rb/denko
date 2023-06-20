//
// This file adds to the Denko class only if DENKO_TONE is defined in Denko.h.
//
#include "Denko.h"
#ifdef DENKO_TONE

// CMD = 20
void Denko::tone() {
  uint16_t frequency = *reinterpret_cast<uint16_t*>(auxMsg);
  uint16_t duration = *reinterpret_cast<uint16_t*>(auxMsg + 2); // in milliseconds
  
  // val is 1 if a duration was given, 0 if not.
  if (val !=0) {
    ::tone(pin, frequency, duration);
  } else {
    ::tone(pin, frequency);
  }
}

// CMD = 21
void Denko::noTone() {
  ::noTone(pin);
}

#endif
