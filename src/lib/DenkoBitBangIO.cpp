//
// Bit-banged implementations which DON'T mimic hardware protocols:
//   - DHT Sensor Family
//   - HC-SRO4 Sensor
//   - TM1637 LEDs
//
#include "Denko.h"

// CMD = 11
//
// Rapidly polls a digital input looking for rising or falling edges,
// recording the time in microseconds between consecutive edges.
// There is an optional reset at the beginning if the pin must be held opposite
// to its idle state to trigger a reading.
//
// Max 65535 microseconds reset time.
// Max 255 microseconds per pulse (between 2 consecutive edges).
// Max 255 pulses counted.
//
// val bit 0   : whether to reset the line first or not (0 = no, 1 = yes)
// val bit 1   : direction to pull the line (0 = low, 1 = high)
// auxMsg[0-1] : unsigned 16-bit reset duration
// auxMsg[2-3] : unsigned 16-bit pulse read timeout (in milliseconds)
// auxMsg[4]   : unsigned 8-bit pulse count limit
// auxMsg[8+]  : reserved as output buffer, will be overwritten
//
void Denko::pulseRead(){
  // Reset
  if (bitRead(val, 0)) {
    uint16_t resetTime = (auxMsg[1] << 8) | auxMsg[0];
    pinMode(pin, OUTPUT);
    digitalWrite(pin, bitRead(val, 1));
    microDelay(resetTime);
  }
  pinMode(pin, INPUT);
  byte state = digitalRead(pin);

  uint16_t timeout = (auxMsg[3] << 8) | auxMsg[2];
  byte pulseCount = 0;

  uint32_t start = millis();
  uint32_t lastWrite = micros();

  while ((millis() - start < timeout) && (pulseCount < auxMsg[4])) {
    if (digitalRead(pin) != state){
      uint32_t now = micros();
      pulseCount++;
      auxMsg[pulseCount+8] = now - lastWrite;
      lastWrite = now;
      state = state ^ 1;
    }
  }

  stream->print(pin); stream->print(':');
  for (byte i=1; i<=pulseCount; i++){
    stream->print(auxMsg[i+8]);
    stream->print((i == pulseCount) ? '\n' : ',');
  }
  if (pulseCount == 0) stream->print('\n');
}

// CMD = 20
//
// pin                : echo pin
// val (lower 8 bits) : trigger pin
//
void Denko::hcsr04Read(){
  // Store number of microseconds to return.
  uint32_t us;

  // Ensure pins are correct direction.
  // This is handled by modeling the sensor as a multipin component instead.
  // pinMode(pin, INPUT);
  // pinMode(val, OUTPUT);

  // Initial pulse on the triger pin.
  digitalWrite(val, LOW);
  microDelay(2);
  digitalWrite(val,HIGH);
  microDelay(10);
  digitalWrite(val,LOW);

  // Wait for the echo, up to 25,000 microseconds.
  us = pulseIn(pin, HIGH, 25000);

  // Send value.
  stream->print(pin);
  stream->print(':');
  stream->print(us);
  stream->print('\n');
}

// CMD = 39
// Used for TM1637. Similar to I2C write, except:
//  - No address written first.
//  - LSBFIRST
//  - (N)ACK ignored, so pins can stay output.
void Denko::shiftOutNine(){
  uint8_t clock = pin;
  uint8_t data = val;
  uint8_t length = auxMsg[0];

  // Idle bus state is both high.
  pinMode(data, OUTPUT);
  pinMode(clock, OUTPUT);
  digitalWrite(data, HIGH);
  digitalWrite(clock, HIGH);
  microDelay(2);

  // Start condition.
  digitalWrite(data, LOW);
  microDelay(2);
  digitalWrite(clock, LOW);
  microDelay(2);

  uint8_t bit;
  for (uint8_t i=0; i<length; i++) {
    // Write 8 bits from byte.
    for (uint8_t j=0; j<8; j++) {
      bit = bitRead(auxMsg[1+i], j);
      digitalWrite(data, bit);
      digitalWrite(clock, HIGH);
      microDelay(2);
      digitalWrite(clock, LOW);
      microDelay(2);
    }
    // Ignore 9th bit (N)ACK
    digitalWrite(data, LOW);
    digitalWrite(clock, HIGH);
    microDelay(2);
    digitalWrite(clock, LOW);
    microDelay(2);
  }

  // Stop condition.
  //
  // Already low since ignoring (N)ACK and pulling data low.
  // digitalWrite(data, LOW);
  digitalWrite(clock, HIGH);
  microDelay(2);
  digitalWrite(data, HIGH);
}
