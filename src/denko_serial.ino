#include "Denko.h"

Denko denko;

void setup() {
  // Wait for serial ready.
  DENKO_SERIAL_IF.begin(115200);
  while(!DENKO_SERIAL_IF);

  // Pass serial stream to denko so it can read/write.
  denko.stream = &DENKO_SERIAL_IF;
}

void loop() {
  denko.run();
}
