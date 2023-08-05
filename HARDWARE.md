# Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet :question: Works in theory. Untested in real hardware.

### AVR/MegaAVR Based in Arduino Products (and Clones)
[![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_avr.yml)
[![MegaAVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_megaavr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_megaavr.yml)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega168      | :green_heart:   | Duemilanove, Diecimila, Pro | Features omitted to save memory. `denko targets` for more info.
| ATmega328      | :green_heart:   | Uno R3, Uno WiFi, Nano, Fio, Pro  |
| ATmega32u4     | :green_heart:   | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB |
| ATmega1280     | :green_heart:   | Mega |
| ATmega2560     | :green_heart:   | Mega2560, Arduino Mega ADK |
| ATmega4809     | :question:      | Nano Every, Uno WiFi Rev2 | No hardware to test, but should work

**Note:** Only USB boards listed. Any board with a supported chip should work, once you can flash it and connect to serial.

### ARM Based Arduino Products (and Clones)
[![SAM3X Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_sam3x.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_sam3x.yml)
[![SAMD Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_samd.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_samd.yml)
[![RA4M1 Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATSAM3X8E      | :yellow_heart:  | Due | Native USB port. Tone, and IR Out don't work.
| ATSAMD21       | :green_heart:   | Zero, M Series, MKR Series | Native USB
| RA4M1          | :yellow_heart:  | Uno R4 Minima, Uno R4 WiFi | IR Out and WS2812 unsupported. UART & Wi-Fi untested

### Arduino Networking

|    Chip               | Status          | Products         | Notes |
| :--------             | :------:        | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | Ethernet Shield  | Wired Ethernet for Uno/Mega pin-compatibles
| HDG204 + AT32UC3      | :question:      | WiFi Shield      | WiFi for Uno. Compiles. No hardware
| ATWINC1500            | :green_heart:   | MKR1000, WiFi Shield 101 | High memory use. Must #define WIFI_101 in sketch (automatic for MKR1000)
| u-blox NINA-W102      | :question:      | Uno WiFi Rev 2, Some MKR & Nano Series | Should be API compatible Wifi.h. No hardware

### Espressif Chips with Built-In Wi-Fi
[![ESP8266 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml)
[![ESP32 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml)

|    Chip        | Status          | Board Tested         | Notes |
| :--------      | :------:        | :---------------     |------ |
| ESP8266        | :green_heart:   | NodeMCU              |
| ESP8285        | :question:      | DOIT ESP-Mx DevKit   | Should be identical to 8266. Not tested in hardware.
| ESP32          | :green_heart:   | DOIT ESP32 DevKit V1 |
| ESP32-S2       | :green_heart:   | LOLIN S2 Pico        | Native USB
| ESP32-S3       | :green_heart:   | LOLIN S3 V1.0.0      | Native USB
| ESP32-C3       | :green_heart:   | LOLIN C3 Mini V2.1.0 | Native USB

**Note:** For ESP32 chips using native USB, make sure `USB CDC On Boot` is `Enabled` in the IDE's `Tools` menu. Flashing from the CLI doesn't automatically enable this, so the IDE is recommended for now.

### Raspberry Pi Microcontrollers
[![RP2040 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml)

|    Chip        | Status          | Board Tested          | Notes |
| :--------      | :------:        | :---------------      |------ |
| RP2040         | :green_heart:   | Raspberry Pi Pico (W) | WiFi only on W version. No WS1812 LED support.

# Single Board Computers

### Raspberry Pi Single Board Computers
**Note:** See the [denko-piboard](https://github.com/denko-rb/denko-piboard) extension to this gem. It uses the peripheral classes from this gem, but swaps out `Board` for `PiBoard`, which uses the Raspberry Pi's built-in GPIO interface. This is still a work-in-progress.

|    Chip        | Status          | Products              | Notes |
| :--------      | :------:        | :---------------      |------ |
| BCM2835        | :yellow_heart:  | Pi 1, Pi Zero (W)     |
| BCM2836/7      | :question:      | Pi 2                  |
| BCM2837A0/B0   | :yellow_heart:  | Pi 3                  |
| BCM2711        | :question:      | Pi 4, Pi 400          |
| BCM2710A1      | :question:      | Pi Zero 2W            |

# Peripherals

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Interfaces

| Name                  | Status          | HW/SW | Component Class          | Notes |
| :---------------      | :------:        | :---  | :--------------          | :---- |
| Digital In            | :green_heart:   | H     | `DigitalIO::Input`       | 1ms - 128ms (4ms default) listen, poll, or read
| Analog In (ADC)       | :green_heart:   | H     | `AnalogIO::Input`        | 1ms - 128ms (16ms default) listen, poll, or read
| Digital Out           | :green_heart:   | H     | `DigitalIO::Output`      |
| Analog Out (DAC)      | :green_heart:   | H     | `AnalogIO::Output`       | Only SAM3X, SAMD21, RA4M1, ESP32, ESP32-S2
| PWM Out               | :green_heart:   | H     | `PulseIO::PWMOutput`     |
| Servo/ESC PWM         | :green_heart:   | H     | See Motor table          | Uses PWM
| Tone Out (Square Wave)| :green_heart:   | H     | `PulseIO::Buzzer`        | Except SAM3X. Uses PWM
| I2C                   | :green_heart:   | H     | `I2C::Bus`               | Predetermined pins from IDE
| I2C Bit Bang          | :heart:         | S     | `I2C::BitBang`           | Any pins
| SPI                   | :green_heart:   | H     | `SPI::Bus`               | Predetermined pins from IDE
| SPI Bit Bang          | :green_heart:   | S     | `SPI::BitBang`           | Any pins
| UART                  | :green_heart:   | H     | `UART::Hardware`         | Except Atmega328, ATmega168, RA4M1
| UART Bit Bang         | :green_heart:   | S     | `UART::BitBang`          | Only ATmega328, ATmega168
| Maxim OneWire         | :green_heart:   | S     | `OneWire::Bus`           | No overdrive
| Infrared Emitter      | :green_heart:   | S     | `PulseIO::IRTransmitter` | Except RA4M1
| Infrared Receiver     | :heart:         | S     | `PulseIO::IRReceiver`    | Doable with existing library
| WS2812                | :green_heart:   | S     | See LED table            | Except RP2040
| ESP32-PCNT            | :heart:         | H     | -                        | Only ESP32. Pulse counter (for encoders)
| ESP32-MCPWM           | :heart:         | H     | -                        | Only ESP32. Motor control PWM

**Note:** When listening, the board checks the pin's value every **_2^n_** milliseconds (**_n_** from **_0_** to **_7_**), without further commands.
Polling and reading follow a call and response pattern.

### Basic Input/Output

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Button           | :green_heart:  | Digital In   | `DigitalIO::Button`        |
| Rotary Encoder   | :green_heart:  | Digital In   | `DigitalIO::RotaryEncoder` | Listens every 1ms
| Potentiometer    | :green_heart:  | Analog In    | `AnalogIO::Potentiometer`  | Smoothing on by default
| Relay            | :green_heart:  | Digital Out  | `DigitalIO::Relay`         |

### LEDs

| Name               | Status             | Interface         | Component Class       | Notes |
| :---------------   | :------:           | :--------         | :---------------      |------ |
| LED                | :green_heart:      | Digi/Ana Out      | `LED::Base`           |
| RGB LED            | :green_heart:      | Digi/Ana Out      | `LED::RGB`            |
| 7 Segment Display  | :yellow_heart:     | Digital Out       | `LED::SevenSegment`   | No decimal point
| TM1637             | :heart:            | BitBang SPI       | `LED::TM1637`         | 4x 7 Segment + Colon
| Neopixel / WS2812B | :yellow_heart:     | Adafruit Library  | `LED::WS2812`         | Not working on RP2040
| Dotstar / APA102   | :green_heart:      | SPI               | `LED::APA102`         |

### Displays

| Name                     | Status         | Interface                    | Component Class     | Notes |
| :---------------         | :------:       | :--------                    | :---------------    |------ |
| HD44780 LCD              | :green_heart:  | Digital Out, Output Register | `Display::HD44780`  |
| SSD1306 OLED             | :yellow_heart: | I2C                          | `Display::SSD1306`  | 1 font, some graphics

### Sound

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Piezo Buzzer     | :green_heart:  | Tone Out     | `PulseIO::Buzzer`          | Frequency > 30Hz

### Motors / Motor Drivers

| Name                 | Status         | Interface      | Component Class    | Notes |
| :---------------     | :------:       | :--------      | :---------------   |------ |
| Generic Hobby Servo  | :green_heart:  | Servo/ESC PWM  | `Motor::Servo`     | Max depends on PWM channel count
| Generic ESC          | :yellow_heart: | Servo/ESC PWM  | `Motor::Servo`     | Works. Needs its own class.
| PCA9685              | :heart:        | I2C            | `PulseIO::PCA9685` | 16ch 12-bit PWM for servo or LED
| L298N                | :green_heart:  | Digi + PWM Out | `Motor::L298`      | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out    | `Motor::Stepper`   | 1ch microstepper (EasyDriver)
| TMC2209              | :heart:        | -              | -                  | 1ch silent stepper driver

### I/O Expansion

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Input Register   | :green_heart:  | SPI        | `SPI::InputRegister` | Tested on CD4021B
| Output Register  | :green_heart:  | SPI        | `SPI::OutputRegister`| Tested on 74HC595
| PCF8574 Expander | :heart:        | I2C        | `DigitalIO::PCF8574` | 8ch bi-directional digital I/O
| ADS1100 ADC      | :heart:        | I2C        | `AnalogIO::ADS1100`  | 15-bit +/- 1ch ADC
| ADS1115 ADC      | :green_heart:  | I2C        | `AnalogIO::ADS1115`  | 15-bit +/- 4ch ADC. Comparator not implemented.
| ADS1118 ADC      | :green_heart:  | SPI        | `AnalogIO::ADS1118`  | 15-bit +/- 4ch ADC + temperature
| PCF8591 ADC/DAC  | :heart:        | I2C        | `AnalogIO::PCF8591`  | 4ch ADC + 1ch DAC, 8-bit resolution
| MCP4725 DAC      | :heart:        | I2C        | `AnalogIO::MCP4275`  | 1ch 12-bit DAC

### Environmental Sensors

| Name             | Status         | Interface   | Component Class    | Notes |
| :--------------- | :------:       | :--------   | :---------------   |------ |
| DS18B20          | :green_heart:  | OneWire     | `Sensor::DS18B20`  | Temp
| DHT 11/21/22     | :green_heart:  | Digi In/Out | `Sensor::DHT`      | Temp/RH
| SHT30            | :heart:        | I2C         | `Sensor::SHT30`    | Temp/RH
| QMP6988          | :heart:        | I2C         | `Sensor::QMP6988`  | Pressure
| BME280           | :green_heart:  | I2C         | `Sensor::BME280`   | Temp/RH/Press
| BMP280           | :green_heart:  | I2C         | `Sensor::BMP280`   | Temp/Press
| HTU21D           | :green_heart:  | I2C         | `Sensor::HTU21D`   | Temp/RH. User register read not implemented.
| HTU31D           | :green_heart:  | I2C         | `Sensor::HTU31D`   | Temp/RH. Diagnostic read not implemented.
| AHT10/15         | :green_heart:  | I2C         | `Sensor::AHT10`    | Temp/RH. Always uses calibrated mode.
| AHT20/21/25      | :green_heart:  | I2C         | `Sensor::AHT20`    | Temp/RH. Always uses calibrated mode + CRC.
| ENS160           | :heart:        | I2C         | `Sensor::ENS160`   | CO2e/TVOC/AQI
| AGS02MA          | :heart:        | I2C         | `Sensor::AGS02MA`  | TVOC
| MAX31850         | :heart:        | OneWire     | `Sensor::MAX31850` | Thermocouple Amplifier

### Light Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| BH1750           | :heart:        | Digital In   | `Sensor::BH1750`   | Ambient Light
| HC-SR501         | :yellow_heart: | Digital In   | `DigitalIO::Input` | PIR. Needs class: `Sensor::HC-SR501`
| AS312            | :heart:        | I2C          | `Sensor::AS312`    | PIR
| APDS9960         | :heart:        | I2C          | `Sensor::APDS9960` | Proximity, RGB, Gesture

### Distance Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| HC-SR04          | :heart:        | Digi In/Out  | `Sensor::HCSR04`   | Ultrasonic, 20-4000mm
| RCWL-9620        | :heart:        | I2C          | `Sensor::RCWL9260` | Ultrasonic, 20-4500mm
| VL53L0X          | :heart:        | I2C          | `Sensor::VL53L0X`  | Laser, 30 - 1000mm
| GP2Y0E03         | :heart:        | I2C          | `Sensor::GP2Y0E03` | Infrared, 40 - 500mm

### Motion Sensors

| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| ADXL345          | :heart:        | I2C       | `Sensor::ADXL345`  | 3-axis Accelerometer
| IT3205           | :heart:        | I2C       | `Sensor::IT3205`   | 3-axis Gyroscope
| HMC5883L         | :heart:        | I2C       | `Sensor::HMC5883L` | 3-axis Compass
| MPU6886          | :heart:        | I2C       | `Sensor::MPU6886`  | 3-axis Gyro + Accel

### Real Time Clocks

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| DS1302           | :heart:        | I2C       | `RTC::DS1302`     |
| DS3231           | :green_heart:  | I2C       | `RTC::DS3231`     | Alarms not implemented

### GPS

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| GT-U7            | :heart:        | UART      | -                 |

### Miscellaneous

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Board EEPROM     | :green_heart:  | Built-In   | `EEPROM::BuiltIn`    | Arduino ARM boards have no EEPROM
| MFRC522          | :heart:        | SPI/I2C    | `DigitalIO::MFRC522` | RFID tag reader / writer
