# Supported Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet :question: Works in theory. Untested in real hardware.

## Espressif ESP32

| Chip           | Support         | Board Tested             | Notes                       | Build Status  |
| :--------      | :------:        | :---------------         |------                       | -----------   |
| ESP32          | :green_heart:   | DOIT ESP32 DevKit V1     |                             | [![ESP32 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml) | 
| ESP32-S2       | :green_heart:   | LOLIN S2 Pico            | Native USB-CDC              | [![ESP32-S2 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32s2.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32s2.yml) |
| ESP32-S3       | :green_heart:   | LOLIN S3 V1.0.0          | Native USB-CDC              | [![ESP32-S3 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32s3.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32s3.yml) | 
| ESP32-C3       | :green_heart:   | LOLIN C3 Mini V2.1.0     | Native USB-CD               | [![ESP32-C3 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32c3.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32c3.yml) |
| ESP32-C6       | :green_heart:   | ESP32-C6-WROOM-1         | Native USB-CDC              | [![ESP32-C6 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32c6.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32c6.yml) |
| ESP32-H2       | :green_heart:   | ESP32-H2-MINI-1          | Native USB-CDC, No Wi-Fi    | [![ESP32-H2 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32h2.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32h2.yml) |
| ESP32-P4       | :green_heart:   | ESP32-P4-Module-DEV-KIT  | Native USB-CDC              | [![ESP32-P4 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32p4.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32p4.yml) |

**Notes for using USB-CDC with ESP32 chips:**

- Be sure to use the ESP32 Arduino core version `3.3.11` or later. Prior `3.x` releases cause USB-CDC to fail intermittently.
- To enable, make sure `Tools -> USB CDC On Boot` is `Enabled`, and `Tools -> USB Mode` is set to `Harware CDC & JTAG` in the Arduino IDE. Flashing from the CLI doesn't automatically enable this, so the IDE is recommended for now.

## Espressif ESP8266

| Chip           | Support         | Board Tested         | Notes                                           | Build Status  |
| :--------      | :------:        | :---------------     |------                                           | -----------   |
| ESP8266        | :green_heart:   | NodeMCU              |                                                 | [![ESP8266 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml) |
| ESP8285        | :question:      | DOIT ESP-Mx DevKit   | Should match 8266. Not tested in hardware.      | [![ESP8285 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp8285.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp8285.yml) |

## Raspberry Pi Microcontrollers

| Chip           | Support         | Board Tested            | Notes                            | Build Status  |
| :--------      | :------:        | :---------------        |------                            | -----------   |
| RP2040         | :green_heart:   | Raspberry Pi Pico (W)   |                                  | [![RP2040 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml) |
| RP2350         | :green_heart:   | Raspberry Pi Pico 2 (W) |                                  | [![RP2350 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_rp2350.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_rp2350.yml) |

## AVR/MegaAVR Based Arduino Products (and Clones)

| Chip           | Support         | Products                                             | Notes                                       | Build Status  |
| :--------      | :------:        | :---------------                                     |------                                       | -----------   |
| ATmega168      | :green_heart:   | Duemilanove, Diecimila, Pro                          | Omits features. `denko targets` for info.   | [![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml) |
| ATmega328      | :green_heart:   | Uno R3, Uno WiFi, Nano, Fio, Pro                     |                                             | [![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml) |
| ATmega32u4     | :green_heart:   | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB  |                                             | [![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml) |
| ATmega1280     | :green_heart:   | Mega                                                 |                                             | [![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml) |
| ATmega2560     | :green_heart:   | Mega2560, Arduino Mega ADK                           |                                             | [![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml) |
| ATmega4809     | :green_heart:   | Nano Every, Uno WiFi Rev2                            |                                             | [![MegaAVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_megaavr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_megaavr.yml) |

**Note:** Only USB boards listed. Any board with a supported chip should work, once you can flash it and connect to serial.

## ARM Based Arduino Products (and Clones)

| Chip           | Support         | Products         | Notes                                   | Build Status  |
| :--------      | :------:        | :--------------- |------                                   | -----------   |
| ATSAM3X8E      | :green_heart:   | Due | Native USB. Tone and infrared not supported          | [![SAM3X Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_atsam3x.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atsam3x.yml) |
| ATSAMD21       | :green_heart:   | Zero, M0 Series, Nano 33 IOT, MKR WiFi 1010 | Native USB   | [![SAMD Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_atsamd21.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atsamd21.yml) |
| RA4M1          | :green_heart:   | Uno R4 Minima, Uno R4 WiFi | Infrared not supported        | [![RA4M1 Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml) |

## AVR Chips from [MightyCore](https://github.com/MCUdude/MightyCore)

| Chip           | Support         | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega1284     | :heart:         | Used in many 8-bit 3D printer boards. |

## Arduino Networking

| Chip                  | Support         | Products         | Notes |
| :--------             | :------:        | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | Ethernet Shield  | Wired Ethernet shield
| HDG204 + AT32UC3      | :question:      | WiFi Shield      | Compiles. No test hardware
| ATWINC1500            | :green_heart:   | MKR1000, WiFi Shield 101 | #define WIFI_101 for shield
| u-blox NINA-W102      | :question:      | Uno WiFi Rev 2, MKR WiFi 1010, Nano 33 IOT | Compiles. No test hardware

## Implemented Interfaces

| Name                  | Status          | HW/SW | Component Class          | Notes |
| :---------------      | :------:        | :---  | :--------------          | :---- |
| Digital In            | :green_heart:   | H     | `DigitalIO::Input`       | 1ms - 128ms (4ms default) listen, poll, or read
| Analog In (ADC)       | :green_heart:   | H     | `AnalogIO::Input`        | 1ms - 128ms (16ms default) listen, poll, or read
| Digital Out           | :green_heart:   | H     | `DigitalIO::Output`      |
| Analog Out (DAC)      | :green_heart:   | H     | `AnalogIO::Output`       | **Only** SAM3X, SAMD21, RA4M1, ESP32, ESP32-S2
| PWM Out               | :green_heart:   | H     | `PulseIO::PWMOutput`     |
| Servo/ESC Motor Drive | :green_heart:   | H     | See Motor Driver Table   | Depends on PWM
| Tone Out (Sq. Wave)   | :green_heart:   | H     | `PulseIO::Buzzer`        | Except SAM3X. Uses PWM
| I2C                   | :green_heart:   | H     | `I2C::Bus`               | Predetermined pins per board
| I2C Bit-Bang          | :green_heart:   | S     | `I2C::BitBang`           | Any pins
| SPI                   | :green_heart:   | H     | `SPI::Bus`               | Predetermined pins per board
| SPI Bit-Bang          | :green_heart:   | S     | `SPI::BitBang`           | Any pins
| UART                  | :green_heart:   | H     | `UART::Hardware`         | **Except** Atmega328, ATmega168
| UART Bit-Bang         | :green_heart:   | S     | `UART::BitBang`          | **Only** ATmega328
| Maxim OneWire         | :green_heart:   | S     | `OneWire::Bus`           | No overdrive
| Infrared Output       | :green_heart:   | S     | `PulseIO::IROutput`      | **Except** SAM3X, RA4M1
| Infrared Input        | :heart:         | S     | `PulseIO::IRInput`       | Doable with existing library
| WS2812 RGB LEDs       | :green_heart:   | S     | `LED::WS2812`            |
| ESP32-PCNT            | :heart:         | H     | -                        | **Only** ESP32. Pulse and encoder counter
| ESP32-MCPWM           | :heart:         | H     | -                        | **Only** ESP32. Motor control PWM

**Note:** When listening, the board checks the pin's value every **_2^n_** milliseconds (**_n_** from **_0_** to **_7_**), without further commands.
Polling and reading follow a call and response pattern.
