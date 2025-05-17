// If using Wi-Fi or Ethernet shield, uncomment this to let the SPI library know.
// #define TXRX_SPI

// Uncomment this line to enable debugging mode.
// #define debug

// Define the version of Denko the board was flashed with so we can verify in Ruby.
#define DENKO_VERSION __VERSION__

// Uncomment these to include features beyond core features.
// #define DENKO_EEPROM
// #define DENKO_ONE_WIRE
// #define DENKO_TONE
// #define DENKO_I2C_BB
// #define DENKO_SPI_BB
// #define DENKO_I2C
// #define DENKO_SPI
// #define DENKO_SERVO
// #define DENKO_UART
// #define DENKO_UART_BB
// #define DENKO_IR_OUT
// #define DENKO_LED_ARRAY

// Include libraries for specific LED array protocols.
#ifdef DENKO_LED_ARRAY
  #define DENKO_LED_WS2812
#endif

// Define number of pins to set up listener storage.
#if defined(ESP32)
  #define PIN_COUNT SOC_GPIO_PIN_COUNT
#else
  #define PIN_COUNT NUM_DIGITAL_PINS
#endif

// Figure out how many LEDC channels are available on ESP32 boards.
#ifdef ESP32
  #define LEDC_CHANNEL_COUNT SOC_LEDC_CHANNEL_NUM
#endif

// Filter for boards that can set their analog write resolution.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__) || defined(_RENESAS_RA_) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040) || defined(ESP8266)
  #define WRITE_RESOLUTION_SETTER
#endif

// Filter for boards that can set their analog read resolution.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__) || defined(_RENESAS_RA_) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040)
  #define READ_RESOLUTION_SETTER
#endif

// Figure out how many open (not connected to a USB port) hardware UARTS there are on the board.
#ifdef DENKO_UART
  // Look for TX pin definitions on RP2040.
  #if defined(RP2040)
    #if defined(PIN_SERIAL2_TX)
      #define DENKO_UARTS 2
    #elif defined(PIN_SERIAL_1_TX)
      #define DENKO_UARTS 1
    #endif

  // ESP32 has either 1 or 2 extra UARTS enabled, depending on chip and board.
  #elif defined(ESP32)
    #define DENKO_UARTS (SOC_UART_NUM - 1)

  // ESP8266 has a single open transmit-only UART.
  #elif defined(ESP8266) && defined(SERIAL_PORT_HARDWARE_OPEN)
    #define DENKO_UARTS 1

  // Define 1 UART for UNO R4 boards. Always use Serial1.
  #elif defined(_RENESAS_RA_)
    #define DENKO_UARTS 1

  // Define 1 UART for ATmega4809.
  #elif defined(__AVR_ATmega4809__) && defined(SERIAL_PORT_HARDWARE)
    #define DENKO_UARTS 1

  // This works for all the Atmel cores exept ATmega4809.
  #else
    #if defined(SERIAL_PORT_HARDWARE3)
      #define DENKO_UARTS 3
    #elif defined(SERIAL_PORT_HARDWARE2)
      #define DENKO_UARTS 2
    #elif defined(SERIAL_PORT_HARDWARE1)
      #define DENKO_UARTS 1
    #endif
  #endif
#endif

#ifdef DENKO_UART_BB
  #include <SoftwareSerial.h>
#endif

// If no high usage features (core sketch), 32 + 16.
#if !defined(DENKO_SHIFT) && !defined (DENKO_I2C) && !defined(DENKO_SPI) && !defined(DENKO_UARTS) && !defined(DENKO_UART_BB) && !defined(DENKO_IR_OUT) && !defined(DENKO_LED_ARRAY)
  #define AUX_SIZE 48
// If using IR_OUT or LED_ARRAY, and not on the ATmega168, 768 + 16.
#elif (defined(DENKO_IR_OUT) || defined(DENKO_LED_ARRAY)) && !defined(__AVR_ATmega168__)
  #define AUX_SIZE 784
// Default aux message size to 256 + 16 bytes.
#else
  #define AUX_SIZE 272
#endif

// Define 'DENKO_SERIAL_IF' as the serial interface to use.
// Uses SerialUSB (left port), which is native USB, on Arduino Due & Zero, or Serial otherwise.
// On many boards, eg. Arduino Leonardo, RP2040, ESP32-S3, Serial is native USB regardless.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__)
  #define DENKO_SERIAL_IF SERIAL_PORT_USBVIRTUAL
  #define DENKO_USB_CDC
  // "Serial" is UART (right port) on Due and Zero, but may be native USB on boards with one port.
  // #define DENKO_SERIAL_IF Serial
#else
  #define DENKO_SERIAL_IF Serial
#endif

// Figure out how much serial buffer we have, tell the computer, and set the ack interval.
// Best performance acknowledging at 64 bytes, or 32 if buffer is only 64.
//
// These are 256/64 regardless of whether native USB CDC or UART bridge.
#if defined(ARDUINO_ARCH_RP2040) || defined(ESP8266) || defined(__SAM3X8E__)
  #define DENKO_SERIAL_BUFFER_SIZE 248
  #define DENKO_RX_ACK_INTERVAL 64

// ESP32 defaults to 256 buffer. Stay one under.
#elif defined(ESP32)
  #define DENKO_SERIAL_BUFFER_SIZE 248
  // H2 and C6 unreliable with CDC. Use UART bridge. Still unreliable ACK before buffer full, like S2.
  #if defined(CONFIG_IDF_TARGET_ESP32H2) || defined(CONFIG_IDF_TARGET_ESP32C6)
    #define DENKO_RX_ACK_INTERVAL 248
  #else
    #ifdef ARDUINO_USB_CDC_ON_BOOT
      // S2 unreliable with acknowledgement before buffer is full.
      #ifdef CONFIG_IDF_TARGET_ESP32S2
        #define DENKO_RX_ACK_INTERVAL 248
      // S3 and C3 are fine acknowledging at half buffer filled.
      #else
        #define DENKO_RX_ACK_INTERVAL 128
      #endif
    // Fall back to 64 if using a UART bridge.
    #else
      #define DENKO_RX_ACK_INTERVAL 64
    #endif
  #endif

// RA4M1 has a 512 Serial buffer.
#elif defined(_RENESAS_RA_)
  #define DENKO_SERIAL_BUFFER_SIZE 504
  #define DENKO_RX_ACK_INTERVAL 64
// SAMD21 is 256/128 in native USB mode ONLY. Must use defaults on programming port to avoid data loss.
#elif defined(__SAMD21G18A__) && defined(DENKO_USB_CDC)
  #define DENKO_SERIAL_BUFFER_SIZE 248
  #define DENKO_RX_ACK_INTERVAL 128
// 32u4 is odd. Size is 63 instead of 64. Interval must be 31. 32 doesn't work at all. Off by 1 errors?
#elif defined(__AVR_ATmega32U4__)
  #define DENKO_SERIAL_BUFFER_SIZE 63
  #define DENKO_RX_ACK_INTERVAL 31
// Defaults
#else
  #define DENKO_SERIAL_BUFFER_SIZE 64
  #define DENKO_RX_ACK_INTERVAL 32
#endif

// Figure out how big the buffer is on the built-in Wire / I2C library.
#ifdef DENKO_I2C
  // RP2040 and SAMD21 can do up to 256, but 255 since 1 byte for length.
  #if defined(ARDUINO_ARCH_RP2040) || defined(__SAMD21G18A__)
    #define DENKO_I2C_BUFFER_SIZE 255
  // ESP32, ESP8266 and megaAVR can do up to 128.
  #elif defined(ESP32) || defined(ESP8266) || defined(__AVR_ATmega4809__)
    #define DENKO_I2C_BUFFER_SIZE 128
  // Fall back to 32 bytes.
  #else
    #define DENKO_I2C_BUFFER_SIZE 32
  #endif
#endif
