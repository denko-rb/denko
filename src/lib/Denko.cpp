/*
  Library for denko ruby gem.
*/
#include "Denko.h"
#include "BoardMap.h"
#ifdef DENKO_EEPROM
  #include "EEPROM.h"
#endif

Denko::Denko(){
  messageFragments[0] = cmdStr;
  messageFragments[1] = pinStr;
  messageFragments[2] = valStr;
  messageFragments[3] = auxMsg;
  resetState();
}

void Denko::rxNotify() {
  stream->print("Rx:");
  stream->print(rxBytes);
  stream->print("\n");
  rxBytes = 0;
}

void Denko::sendHalt() {
  stream->print("Hlt");
  stream->print("\n");
}

// CMD = 92
// Expose this for diagnostics and testing.
void Denko::sendReady() {
  stream->print("Rdy");
  stream->print("\n");
}

void Denko::run(){
  if (rxBytes != 0) rxNotify();

  while(stream->available()) {
    parse(stream->read());
    rxBytes ++;
    // Acknowledge when we've received half as many bytes as the serial buffer.
    if (rxBytes >= DENKO_RX_ACK_INTERVAL) rxNotify();
  }

  #ifdef DENKO_UARTS
    uartUpdateListeners();
  #endif

  #ifdef DENKO_UART_BB
    uartBBUpdateListener();
  #endif

  // Run denko's listeners.
  updateListeners();
}

void Denko::parse(byte c) {
  if ((fragmentIndex == 0) && (charIndex == 0) && ((c & 0b10000000) != 0)) {
    dWrite((c & 0b00111111), ((c & 0b01000000) >> 6), false);
    return;
  }

  if ((c == '\n') || (c == '\\')) {
    // If last char was a \, this \ or \n is escaped.
    if(escaping){
      append(c);
      escaping = false;
    }

    // If EOL, process and reset.
    else if (c == '\n'){
      append('\0');
      if ((fragmentIndex > 0) || (charIndex > 1)) process();
      fragmentIndex = 0;
      charIndex = 0;
    }

    // Backslash is the escape character.
    else if (c == '\\') escaping = true;
  }

  // If fragment delimiter, terminate current fragment and move to next.
  // Unless we're in the auxillary message fragment, then just append.
  else if (c == '.') {
    if (fragmentIndex < 3) {
      escaping = false;
      append('\0');
      fragmentIndex++;
      charIndex = 0;
    } else {
      append(c);
    }
  }

  // Else just append the character.
  else {
    escaping = false;
    append(c);
  }
}

void Denko::append(byte c) {
  messageFragments[fragmentIndex][charIndex] = c;
  charIndex++;
}

void Denko::process() {
  cmd = atoi((char *)cmdStr);
  pin = atoi((char *)pinStr);
  val = atoi((char *)valStr);

  // Call the command.
  switch(cmd) {
    // Implemented in DenkoCoreIO.cpp
    case 0:  setMode             (pin, val);        break;
    case 1:  dWrite              (pin, val, false); break;
    case 2:  dRead               (pin);             break;
    case 3:  pwmWrite            (pin, val, false); break;
    case 4:  dacWrite            (pin, val, false); break;
    case 5:  aRead               (pin);             break;
    case 6:  setListener         (pin, val, auxMsg[0], auxMsg[1], false); break;

    // Implemented in DenkoEEPROM.cpp
    #ifdef DENKO_EEPROM
    case 7:  eepromRead           (); break;
    case 8:  eepromWrite          (); break;
    #endif

    // Implemented in DenkoBitBangIO.cpp
    case 9:  pulseRead            (); break;
    case 20: hcsr04Read           (); break;
    case 39: shiftOutNine         (); break;

    // Implemented in DenkoServo.cpp
    #ifdef DENKO_SERVO
    case 10:  servoToggle         (); break;
    case 11:  servoWrite          (); break;
    #endif

    // Implemented in DenkoSerialBB.cpp
    #ifdef DENKO_UART_BB
    case 12: uartBBSetup (); break;
    case 13: uartBBWrite (); break;
    #endif

    // Implemented in DenkoUART.cpp
    #ifdef DENKO_UARTS
    case 14: uartSetup  (); break;
    case 15: uartWrite  (); break;
    #endif

    // Implemented in DenkoIROut.cpp
    #ifdef DENKO_IR_OUT
    case 16: irSend       (); break;
    #endif

    // Implemented in DenkoTone.cpp
    #ifdef DENKO_TONE
    case 17: tone         (); break;
    case 18: noTone       (); break;
    #endif

    // Implemented in DenkoAddressableLED.cppp
    #ifdef DENKO_LED_ARRAY
    case 19: showLEDArray        ();   //cmd = 19
    #endif

    // Implemented in DenkoSPIBB.cpp
    #ifdef DENKO_SPI_BB
    case 21: {
      // Unpack read and write lengths from their 3 shared bytes.
      uint16_t  readLength  = (((uint16_t)auxMsg[3] & 0xF0) << 4) | auxMsg[1];
      uint16_t  writeLength = (((uint16_t)auxMsg[3] & 0x0F) << 8) | auxMsg[2];

      spiBBtransfer (auxMsg[4], auxMsg[5], auxMsg[6], pin, auxMsg[0], readLength, writeLength, &auxMsg[8]);
      break;
    }
    case 22: spiBBaddListener    ();  break;
    #endif

    // Implemented in DenkoSPI.cpp
    #ifdef DENKO_SPI
    case 26: {
      // Do this since RP2040 crashes with reinterpet_cast of uint32_t.
      uint32_t  clockRate  = (uint32_t)auxMsg[4];
                clockRate |= (uint32_t)auxMsg[5] << 8;
                clockRate |= (uint32_t)auxMsg[6] << 16;
                clockRate |= (uint32_t)auxMsg[7] << 24;

      // Unpack read and write lengths from their 3 shared bytes.
      uint16_t  readLength  = (((uint16_t)auxMsg[3] & 0xF0) << 4) | auxMsg[1];
      uint16_t  writeLength = (((uint16_t)auxMsg[3] & 0x0F) << 8) | auxMsg[2];

      spiTransfer(clockRate, pin, auxMsg[0], readLength, writeLength, &auxMsg[8]);
      break;
    }
    case 27: spiAddListener   ();  break;
    #endif

    // Implemented in DenkoSPI.cpp
    #if defined(DENKO_SPI) || defined(DENKO_SPI_BB)
    case 28: spiRemoveListener();  break;
    #endif

    // Implemented in DenkoI2CBB.cpp
    #ifdef DENKO_I2C_BB
    case 30: i2c_bb_search       ();  break;
    case 31: i2c_bb_write        ();  break;
    case 32: i2c_bb_read         ();  break;
    #endif

    // Implemented in DenkoI2C.cpp
    #ifdef DENKO_I2C
    case 33: i2cSearch           ();  break;
    case 34: i2cWrite            ();  break;
    case 35: i2cRead             ();  break;
    #endif

    // Implemented in DenkoOneWire.cpp
    #ifdef DENKO_ONE_WIRE
    case 41: owReset             ();  break;
    case 42: owSearch            ();  break;
    case 43: owWrite             ();  break;
    case 44: owRead              ();  break;
    #endif

    // Implemented in this file.
    case 90: handshake                ();  break;
    case 91: resetState               ();  break;
    case 92: sendReady                ();  break;
    case 95: setRegisterDivider       ();  break;
    case 96: setAnalogWriteResolution ();  break;
    case 97: setAnalogReadResolution  ();  break;
    case 98: binaryEcho               ();  break;
    case 99: microDelay(*reinterpret_cast<uint16_t*>(auxMsg)); break;

    // Should send a "feature not implemented" message as default.
    default:                          break;
  }
}

//
// Every 1000 microseconds count a tick and call the listeners.
// Each core listener has its own divider, so it can read every
// 1, 2, 4, 8, 16, 32, 64 or 128 ticks, independent of the others.
//
// Register listeners are still on a global divider for now.
// Analog and register listeners always send values even if not changed.
// Digital listeners only send values on change.
//
void Denko::updateListeners() {
  currentTime = micros();
  timeDiff = currentTime - lastTime;

  if (timeDiff > 999) {
    // Add a tick for every 1000us passed.
    tickCount = tickCount + (timeDiff / 1000);

    // lastTime for next run is currentTime offset by remainder.
    lastTime = currentTime - (timeDiff % 1000);

    updateCoreListeners();

    // SPI register Listeners
    #if defined(DENKO_SPI) || defined(DENKO_SPI_BB)
      if (tickCount % registerDivider == 0) spiUpdateListeners();
    #endif
  }
}

// CMD = 90
void Denko::handshake() {
  // Reset the I2C interface.
  // Some boards (like the ESP32-S2) behave badly without this.
  #ifdef DENKO_I2C
    i2cEnd();
  #endif

  // Reset all the state variables.
  resetState();

  // Reset this so we never send Rx along with ACK:
  rxBytes = 0;

  // First handshake value is BOARD_MAP if set.
  stream->print("ACK:");
  #ifdef BOARD_MAP
    stream->print(BOARD_MAP);
  #endif

  // Second is DENKO_VERSION.
  stream->print(',');
  #ifdef DENKO_VERSION
    stream->print(DENKO_VERSION);
  #endif

  // Third is serial buffer size.
  stream->print(',');
  stream->print(DENKO_SERIAL_BUFFER_SIZE);

  // Fourth is AUX_SIZE.
  stream->print(',');
  stream->print(AUX_SIZE);

  // Fifth is EEPROM size. None on Due or Zero.
  stream->print(',');
  #if defined(EEPROM_EMULATED)
  	stream->print(EMULATED_EEPROM_LENGTH);
  #elif defined(DENKO_EEPROM)
	  stream->print(EEPROM.length());
  #endif

  // Sixth is I2C buffer size.
  stream->print(',');
  #ifdef DENKO_I2C
  	stream->print(DENKO_I2C_BUFFER_SIZE);
  #endif

  // End
  stream->print('\n');
}

// CMD = 91
void Denko::resetState() {
  clearCoreListeners();
  #if defined(DENKO_SPI) || defined(DENKO_SPI_BB)
    spiClearListeners();
  #endif
  #ifdef ESP32
    ledcDetachAll();
  #endif
  registerDivider = 8; // Update register listeners every ~8ms.
  fragmentIndex = 0;
  charIndex = 0;
  tickCount = 0;
  lastTime = micros();
}

// CMD = 95
// Set the register read divider. Powers of 2 up to 128 are valid.
void Denko::setRegisterDivider() {
  registerDivider = val;
}

// CMD = 96
// Set the analog write resolution.
void Denko::setAnalogWriteResolution() {
  #ifdef WRITE_RESOLUTION_SETTER
    #ifdef ESP32
      esp32AnalogWRes = val;
    #else
      analogWriteResolution(val);
    #endif
  #endif
}

// CMD = 97
// Set the analog read resolution.
void Denko::setAnalogReadResolution() {
  #ifdef READ_RESOLUTION_SETTER
    analogReadResolution(val);
  #endif
}

// CMD = 98
// Test to receive binary data and echo it back (as ASCII for now).
void Denko::binaryEcho() {
  // Respond on whatever pin was given.
  stream->print(pin);
  stream->print(':');

  // Echo bytes from aux back to stream. Val is data length.
  for (uint16_t i=0; i<val; i++) {
    stream->print(auxMsg[i]);
    stream->print(',');
  }

  // End response.
  stream->print('\n');
}

// CMD = 99
// Use a different blocking microsecond delay on different platforms.
void Denko::microDelay(uint32_t microseconds){
  #if defined(ESP32)
    esp_rom_delay_us(microseconds);
  #else
    delayMicroseconds(microseconds);
  #endif
}
