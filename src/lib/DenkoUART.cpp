#include "Denko.h"
#ifdef DENKO_UARTS

void Denko::uartBegin(uint8_t index, uint32_t baud) {
  #if DENKO_UARTS
    if (index == 1) {
      uarts[1] = &Serial1;
      Serial1.begin(baud);
    }
  #endif
  #if (DENKO_UARTS == 2) || (DENKO_UARTS == 3)
    else if (index == 2) {
      uarts[2] = &Serial2;
      Serial2.begin(baud);
    }
  #endif
  #if (DENKO_UARTS == 3)
    else if (index == 3){
      uarts[3] = &Serial3;
      Serial3.begin(baud);
    }
  #endif
}

void Denko::uartEnd(uint8_t index) {
  #if DENKO_UARTS
    if (index == 1) {
      Serial1.end();
    }
  #endif
  #if (DENKO_UARTS == 2) || (DENKO_UARTS == 3)
    else if (index == 2) {
      Serial2.end();
    }
  #endif
  #if (DENKO_UARTS == 3)
    else if (index == 3){
      Serial3.end();
    }
  #endif
  uartListenStates[index] = false;
  uartRxPins[index] = NULL;
}

// CMD = 13
// Start or stop one of the open hardware UARTS on the board.
//
// pin
//   Bit 0..1  = UART index (Serial1, Serial2 or Serial 3)
//   Bit 2..5  = < unused >
//   Bit 6     = Starting or stopping? 0 = STOP, 1 = START
//   Bit 7     = If starting, read or not? 0 = NO, 1 = YES
//
// val         = < unused >
// auxMsg[0-3] = Baud rate if starting.
//
void Denko::uartSetup() {
  // Don't do anything if UART index is out of range.
  uint8_t index  = pin & 0b00000011;
  if ((index < 1) || (index > DENKO_UARTS)) return;

  uint8_t enable = pin & 0b01000000;
  uint8_t listen = pin & 0b10000000;

  if (enable > 0) {
    // RP2040 crashes with 32-bit reinterpret_cast.
    uint32_t  baud  = (uint32_t)auxMsg[0];
              baud |= (uint32_t)auxMsg[1] << 8;
              baud |= (uint32_t)auxMsg[2] << 16;
              baud |= (uint32_t)auxMsg[3] << 24;

    // Serial1 on ESP8266 can't read.
    #ifndef ESP8266
      if (listen > 0) {
        uartListenStates[index] = true;

        // Use "virtual pins" 251 - 253 to represent the UARTs;
        uartRxPins[index] = 250 + index;
      }
    #endif

    uartBegin(index, baud);
  } else {
    uartEnd(index);
  }
}

// CMD = 14
// Write bytes to the Tx pin of one of the UARTS
//
// pin         = UART index to write to (Serial1, Serial2 or Serial 3)
// val         = Length of data bytes
// auxMsg[0+]  = Data bytes
//
void Denko::uartWrite() {
  if ((pin < 1) || (pin > DENKO_UARTS)) return;
  uarts[pin]->write(auxMsg, val);
}

void Denko::uartUpdateListeners() {
  // Start from Serial1, up to highest available.
  for (byte i = 1; i <= DENKO_UARTS; i++) {
    if ((uartListenStates[i]) && uarts[i]->available()) {
      stream->print(uartRxPins[i]);
      stream->print(':');

      char tempChar;
      while (uarts[i]->available()) {
        tempChar = uarts[i]->read();
        // Escape backslashes and newlines.
        if ((tempChar == '\\') || (tempChar == '\n')) stream->print('\\');
        stream->print(tempChar);
      }
      stream->print('\n');
    }
  }
}
#endif
