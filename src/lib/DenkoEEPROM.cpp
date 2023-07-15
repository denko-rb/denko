//
// Basic EEPROM read and write functionality.
//
#include "Denko.h"

#ifdef DENKO_EEPROM
#include <EEPROM.h>

// Emulate 512 bytes of EEPROM on ESP chips and the RP2040.
#if defined(ESP8266) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040)
  #define EEPROM_EMULATED
  #define EMULATED_EEPROM_LENGTH 512
#endif

// CMD = 6
// Read from the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to read
// auxMsg[0-1] = start address
//
void Denko::eepromRead(){
  if (val > 0) {
	  #if defined(EEPROM_EMULATED)
	    EEPROM.begin(EMULATED_EEPROM_LENGTH);
    #endif
	  
    uint16_t startAddress = ((uint16_t)auxMsg[1] << 8) | auxMsg[0];

    // Use pin 254 as a "virtual pin" for the built-in EEPROM.
    stream->print("254");
    stream->print(':');
    stream->print(startAddress);
    stream->print('-');

    for (byte i = 0;  (i < val);  i++) {
      stream->print(EEPROM.read(startAddress + i));
      stream->print((i+1 == val) ? '\n' : ',');
    }
	
  	#if defined(EEPROM_EMULATED)
  	  EEPROM.end();
  	#endif
  }
}

// CMD = 7
// Write to the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to write
// auxMsg[0-1] = start address
// auxMsg[2+]  = bytes to write
//
void Denko::eepromWrite(){
  if (val > 0) {
  	#if defined(EEPROM_EMULATED)
  	  EEPROM.begin(EMULATED_EEPROM_LENGTH);
  	#endif
	  
    uint16_t startAddress = ((uint16_t)auxMsg[1] << 8) | auxMsg[0];

    for (byte i = 0;  (i < val);  i++) {
	  EEPROM.write(startAddress + i, auxMsg[2+i]);
    }
	
  	#if defined(EEPROM_EMULATED)
  	  EEPROM.end();
  	#endif
  }
}
#endif