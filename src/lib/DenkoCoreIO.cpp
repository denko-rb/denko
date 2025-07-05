#include "Denko.h"

// CMD = 00
// Set up a single pin for the desired type of input or output.
void Denko::setMode(byte p, byte m) {
  //
  // Use the lowest 4 bits of m to set different input/output modes.
  // Also enables/disables peripherals for certain targets.
  //
  // OUTPUT MODES:
  // 0000 = Digital Output
  // 0010 = PWM Ouptut
  // 0100 = DAC Output
  // 0110 = Open Drain Output  (Only ESP32 implements this, and we don't really use it)
  // 1000 = Open Source Output (Nothing implements this yet)
  //
  // INPUT MODES
  // 0001 = Input with no pull bias
  // 0011 = Input with internal pulldown, if available.
  // 0101 = Input with internal pullup, if available.
  m = m & 0b00001111;

  #if defined(ESP32)
    // Disable attached DAC if leaving DAC mode.
    #if defined(SOC_DAC_SUPPORTED)
        if (m != 0b0100) dacDisable(p);
    #endif

    // Attach or detach LEDC channel whether entering or leaving PWM mode.
    if (m == 0b0010) {
      // auxMsg[0..3] is frequency, [4..7] is resolution.
      uint32_t freq = *reinterpret_cast<uint32_t *>(auxMsg);
      uint8_t  res  = *reinterpret_cast<uint8_t *>(auxMsg + 4);
      // Fallback to defaults.
      if (freq == 0) freq = 1000;
      if (res  == 0) res  = esp32AnalogWRes;
      ledcAttach(p, freq, res);
      return;
    } else {
      ledcDetach(p);
    }
  #endif

  // On the SAMD21 and RA4M1, mode needs to be INPUT when using the DAC.
  #if defined(__SAMD21G18A__) || defined(_RENESAS_RA_)
    if (m == 0b0100){
      pinMode(p, INPUT);
      return;
    }
  #endif

  // Handle INPUT_* states on boards implementing them.
  #ifdef INPUT_PULLDOWN
  if (m == 0b0011) {
    pinMode(p, INPUT_PULLDOWN);
    return;
  }
  #endif

  #ifdef INPUT_PULLUP
  if (m == 0b0101) {
    pinMode(p, INPUT_PULLUP);
    return;
  }
  #endif

  // Handle OUTPUT_* states on boards implementing them.
  #ifdef OUTPUT_OPEN_DRAIN
  if (m == 0b0110) {
    pinMode(p, OUTPUT_OPEN_DRAIN);
    return;
  }
  #endif

  #ifdef OUTPUT_OPEN_SOURCE
  if (m == 0b1000) {
    pinMode(p, OUTPUT_OPEN_SOURCE);
    return;
  }
  #endif

  // Handle standard INPUT and OUTPUT states.
  // Allows INPUT_* to fallback to INPUT when not implemented.
  if (bitRead(m, 0) == 0) {
    pinMode(p, OUTPUT);
  } else {
    pinMode(p, INPUT);
  }

  // Write high to set pullup for AVRs that use this method.
  #ifdef __AVR__
    if (m == 0b0101) digitalWrite(p, HIGH);
  #endif
}

// CMD = 01
// Write a digital output pin. 0 for LOW, 1 or >0 for HIGH.
void Denko::dWrite(byte p, byte v, boolean echo) {

  #ifdef __SAMD21G18A__
    // digitalWrite doesn't implicitly disconnect PWM on the SAMD21.
    pinMode(p, OUTPUT);
  #endif

  #ifdef ESP32
    // Disconnect any DAC or LEDC peripheral the pin was using.
    // Without this, setting GPIO level has no effect.
    // NOTE: Does not release the LEDC channel or config. Can reattach in aWrite.
    #if defined(SOC_DAC_SUPPORTED)
      dacDisable(p);
    #endif
    ledcDetach(p);
  #endif

  if (v == 0) {
    digitalWrite(p, LOW);
  }
  else {
    digitalWrite(p, HIGH);
  }
  if (echo) coreResponse(p, v);
}

// CMD = 02
// Read a digital input pin. 0 for LOW, 1 for HIGH.
byte Denko::dRead(byte p) {
  byte rval = digitalRead(p);
  coreResponse(p, rval);
  return rval;
}

// CMD = 03
// Write an analog output pin. 0 for LOW, up to 255 for HIGH @ 8-bit resolution.
void Denko::pwmWrite(byte p, int v, boolean echo) {
  #ifdef ESP32
    ledcWrite(p, v);
  #else
    analogWrite(p,v);
  #endif

  if (echo) coreResponse(p, v);
}

#ifdef ESP32
void Denko::ledcDetachAll() {
  for(byte i=0; i<255; i++) ledcDetach(i);
}
#endif

// CMD = 04
// Write to a DAC (digital to analog converter) pin.
// This outputs a true analog resolution, unlike PWM.
void Denko::dacWrite(byte p, int v, boolean echo) {
  #if defined(ESP32) && defined(SOC_DAC_SUPPORTED)
    ::dacWrite(p, v);
  #endif

  #if defined(__SAM3X8E__) || defined(__SAMD21G18A__) || defined(_RENESAS_RA_)
    analogWrite(p, v);
  #endif
}

// CMD = 05
// Read an analog input pin. 0 for LOW, up to 1023 for HIGH @ 10-bit resolution.
int Denko::aRead(byte p) {
  int rval = analogRead(p);
  coreResponse(p, rval);
  return rval;
}

// Simple response for core listeners, or any response with the pin:value pattern.
void Denko::coreResponse(int p, int v){
  stream->print(p);
  stream->print(':');
  stream->print(v);
  stream->print('\n');
}

// CMD = 06
// Enable, disable and change settings for core (digital/analog) listeners.
// See Denko.h for settings and mask layout.
void Denko::setListener(byte p, boolean enabled, byte analog, byte exponent, boolean local){
  // Pre-format the settings into a mask byte.
  byte settingMask = 0;
  if (enabled)  settingMask = settingMask | 0b10000000;
  if (analog)   settingMask = settingMask | 0b1000000;
  if (local)    settingMask = settingMask | 0b0010000;
  settingMask = settingMask | exponent;

  // If an existing listener was already using this pin, just update settings.
  boolean found = false;
  for(byte i=0; i<PIN_COUNT; i++){
    if (listeners[i][1] == p){
      found = true;
      if (bitRead(listeners[i][0], 4) == 0) {
        listeners[i][0] = settingMask;
      } else if(local) {
        // Only allow local code to update local listeners.
        listeners[i][0] = settingMask;
      }
      break;
    }
  }

  // If this pin wasn't used before, take the lowest index inactive listener.
  if (!found){
    for(byte i=0; i<PIN_COUNT; i++){
      if (bitRead(listeners[i][0], 7) == 0){
        listeners[i][0] = settingMask;
        listeners[i][1] = p;
        break;
      }
    }
  }

  // Keep track of how far into the listener array to go when updating.
  findLastActiveListener();
}

// Runs once on every loop to update necessary listeners.
void Denko::updateCoreListeners() {
  for (byte i = 0; i <= lastActiveListener; i++){
    // Check if active.
    if (bitRead(listeners[i][0], 7) == 1){
      // Check if to update it on this tick.
	    // Divider exponent is last 3 bits of settings.
      byte exponent = listeners[i][0] & 0B00000111;
      byte divider = dividerMap[exponent];
      if(tickCount % divider == 0){
        // Check if digital or analog.
        if (bitRead(listeners[i][0], 6) == 1){
          analogListenerUpdate(i);
        } else {
          digitalListenerUpdate(i);
        }
      }
    }
  }
}

// Handle a single analog listener when it needs to read.
void Denko::analogListenerUpdate(byte i){
  int rval = analogRead(listeners[i][1]);
  coreResponse(listeners[i][1], rval);
}

// Handle a single digital listener when it needs to read.
void Denko::digitalListenerUpdate(byte i){
  byte rval = digitalRead(listeners[i][1]);

  if (rval != bitRead(listeners[i][0], 5)){
    // State for digital listeners is stored in byte 5 of the listener itself.
    bitWrite(listeners[i][0], 5, rval);
    coreResponse(listeners[i][1], rval);
  }
}

// Gets called by Denko::reset to clear all listeners set by the remote client.
void Denko::clearCoreListeners(){
  for (int i = 0; i < PIN_COUNT; i++){
    // Only clear listeners if they were started by the remote client.
    // Leaves listeners started by local code running.
    if (bitRead(listeners[i][0], 4) == 0) {
      listeners[i][0] = 0;
      listeners[i][1] = 0;
    }
  }
  findLastActiveListener();
}

// Track the last active listener whenever changes are made.
// Call this after setting or clearing any listeners.
void Denko::findLastActiveListener(){
  for(byte i=0; i<PIN_COUNT; i++){
    if (bitRead(listeners[i][0], 7) == 1){
      lastActiveListener = i;
    }
  }
}
