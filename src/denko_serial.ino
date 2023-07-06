#include "Denko.h"

Denko denko;

void setup() {
  // Wait for serial ready.
  DENKO_SERIAL_IF.begin(115200);
  while(!DENKO_SERIAL_IF);

  // Pass serial stream to denko so it can read/write.
  denko.stream = &DENKO_SERIAL_IF;

  // Add listener callbacks for local logic.
  denko.digitalListenCallback = onDigitalListen;
  denko.analogListenCallback = onAnalogListen;
}

void loop() {
  denko.run();
}

// This runs every time a digital pin that denko is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that denko is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
