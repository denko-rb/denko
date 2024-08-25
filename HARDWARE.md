# Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet :question: Works in theory. Untested in real hardware.

### Espressif Chips with Wi-Fi (Except H2)
[![ESP8266 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp8266.yml)
[![ESP32 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32.yml)
[![ESP32-C3 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32c3.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32c3.yml)
[![ESP32-C6 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32c6.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32c6.yml)
[![ESP32-H2 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32h2.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32h2.yml)
[![ESP32-S2 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32s2.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32s2.yml)
[![ESP32-S3 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_esp32s3.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_esp32s3.yml)

|    Chip        | Status          | Board Tested         | Notes |
| :--------      | :------:        | :---------------     |------ |
| ESP8266        | :green_heart:   | NodeMCU              |
| ESP8285        | :question:      | DOIT ESP-Mx DevKit   | Should be identical to 8266. Not tested in hardware.
| ESP32          | :green_heart:   | DOIT ESP32 DevKit V1 |
| ESP32-S2       | :green_heart:   | LOLIN S2 Pico        | Native USB
| ESP32-S3       | :green_heart:   | LOLIN S3 V1.0.0      | Native USB
| ESP32-C3       | :green_heart:   | LOLIN C3 Mini V2.1.0 | Native USB
| ESP32-H2       | :yellow_heart:  | ESP32-H2-MINI-1      | Has no Wi-Fi. Native USB unreliable. Use UART bridge instead.
| ESP32-C6       | :yellow_heart:  | ESP32-C6-WROOM-1     | Native USB unreliable. Use UART bridge instead.

**Note:** For ESP32 chips using native USB, make sure `USB CDC On Boot` is `Enabled` in the IDE's `Tools` menu. Flashing from the CLI doesn't automatically enable this, so the IDE is recommended for now.

### AVR/MegaAVR Based Arduino Products (and Clones)
[![AVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_avr.yml)
[![MegaAVR Build Status](https://github.com/denko-rb/denko/actions/workflows/build_atmega_megaavr.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atmega_megaavr.yml)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega168      | :green_heart:   | Duemilanove, Diecimila, Pro | Omits features. `denko targets` for info.
| ATmega328      | :green_heart:   | Uno R3, Uno WiFi, Nano, Fio, Pro  |
| ATmega32u4     | :green_heart:   | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB |
| ATmega1280     | :green_heart:   | Mega |
| ATmega2560     | :green_heart:   | Mega2560, Arduino Mega ADK |
| ATmega4809     | :green_heart:   | Nano Every, Uno WiFi Rev2 |

**Note:** Only USB boards listed. Any board with a supported chip should work, once you can flash it and connect to serial.

### ARM Based Arduino Products (and Clones)
[![SAM3X Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_atsam3x.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atsam3x.yml)
[![SAMD Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_atsamd21.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_atsamd21.yml)
[![RA4M1 Build Satus](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_ra4m1.yml)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATSAM3X8E      | :yellow_heart:  | Due | Uses Native USB. Tone and IR Out don't work.
| ATSAMD21       | :green_heart:   | Zero, M0 Series, Nano 33 IOT, MKR WiFi 1010 | Native USB
| RA4M1          | :yellow_heart:  | Uno R4 Minima, Uno R4 WiFi | IR and WS2812 libraries don't support this yet

### Arduino Networking

|    Chip               | Status          | Products         | Notes |
| :--------             | :------:        | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | Ethernet Shield  | Wired Ethernet for Uno/Mega pin-compatibles
| HDG204 + AT32UC3      | :question:      | WiFi Shield      | Compiles, but no hardware
| ATWINC1500            | :green_heart:   | MKR1000, WiFi Shield 101 | #define WIFI_101 for shield. Automatic for MKR1000
| u-blox NINA-W102      | :question:      | Uno WiFi Rev 2, MKR WiFi 1010, Nano 33 IOT | Should work. No hardware

### AVR Chips from [MightyCore](https://github.com/MCUdude/MightyCore)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega1284     | :heart:         | Used in many 8-bit 3D printer boards. | 

### Raspberry Pi Microcontrollers
[![RP2040 Build Status](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/denko-rb/denko/actions/workflows/build_rp2040.yml)

|    Chip        | Status          | Board Tested          | Notes |
| :--------      | :------:        | :---------------      |------ |
| RP2040         | :green_heart:   | Raspberry Pi Pico (W) | WiFi only on W version. No WS1812 LED support.

# Single Board Computers

See the [denko-piboard](https://github.com/denko-rb/denko-piboard) extension to this gem. It uses the peripheral classes from this gem, but swaps out `Board` for `PiBoard`. This uses the SBC's onboard GPIO header, with standard Linux drivers, instead of an attached microcontroller.

In theory, this should work on any well supported SBC, with a recent version of Linux. The list below is confirmed working hardware.

|    Chip        | Status          | Products                               | Notes |
| :--------      | :------:        | :----------------------                |------ |
| Allwinner H618 | :green_heart:   | Orange Pi Zero 2 W                     |
| BCM2835        | :green_heart:   | Raspberry Pi 1, Raspberry Pi Zero (W)  |
| BCM2836/7      | :question:      | Raspberry Pi 2                         |
| BCM2837A0/B0   | :green_heart:   | Raspberry Pi 3                         |
| BCM2711        | :green_heart:   | Raspberry Pi 4, Raspberry Pi 400       |
| BCM2710A1      | :green_heart:   | Raspberry Pi Zero 2W                   |
| BCM2712        | :question:      | Raspberry Pi 5                         |

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
| I2C Bit Bang          | :green_heart:   | S     | `I2C::BitBang`           | Any pins. Timing may not be perfect for some devices?
| SPI                   | :green_heart:   | H     | `SPI::Bus`               | Predetermined pins from IDE
| SPI Bit Bang          | :green_heart:   | S     | `SPI::BitBang`           | Any pins
| UART                  | :green_heart:   | H     | `UART::Hardware`         | Except Atmega328, ATmega168
| UART Bit Bang         | :green_heart:   | S     | `UART::BitBang`          | Only ATmega328
| Maxim OneWire         | :green_heart:   | S     | `OneWire::Bus`           | No overdrive
| Infrared Emitter      | :green_heart:   | S     | `PulseIO::IRTransmitter` | Except SAM3X, RA4M1
| Infrared Receiver     | :heart:         | S     | `PulseIO::IRReceiver`    | Doable with existing library
| WS2812                | :green_heart:   | S     | See LED table            | Except RP2040, RA4M1
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
| 8x8 LED (MAX7219)  | :heart:            | SPI               | `LED::MAX7219`        |
| TM1637             | :heart:            | BitBang SPI       | `LED::TM1637`         | 4x 7 Segment + Colon
| Neopixel / WS2812B | :yellow_heart:     | Adafruit Library  | `LED::WS2812`         | Not working on RP2040
| Dotstar / APA102   | :green_heart:      | SPI               | `LED::APA102`         |

### Displays

| Name                     | Status         | Interface                    | Component Class     | Notes |
| :---------------         | :------:       | :--------                    | :---------------    |------ |
| HD44780 LCD              | :green_heart:  | Digital Out, Output Register | `Display::HD44780`  |
| SSD1306 OLED             | :yellow_heart: | I2C                          | `Display::SSD1306`  | 1 font, some graphics
| ST7565R (128x64 Mono)    | :heart:        | SPI                          | `Display::ST7565R`  |
| ST7735S (160x128 RGB)    | :heart:        | SPI                          | `Display::ST7735S`  |
| ILI9341 (240x320 RGB)    | :heart:        | SPI                          | `Display::ILI9341`  |
| GC9107 (128x128 RGB)     | :heart:        | SPI                          | `Display::GC9107`   |
| GC9A01 (240x240 Round)   | :heart:        | SPI                          | `Display::GCA9A01`  |
| IL0373 (212x104 E-Paper) | :heart:        | SPI                          | `Display::IL0373`   |

### Sound

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Piezo Buzzer     | :green_heart:  | Tone Out     | `PulseIO::Buzzer`          | Frequency > 30Hz

### Motors / Motor Drivers

| Name                 | Status         | Interface      | Component Class    | Notes |
| :---------------     | :------:       | :--------      | :---------------   |------ |
| Generic Hobby Servo  | :green_heart:  | Servo/ESC PWM  | `Motor::Servo`     | Max depends on PWM channel count
| Generic ESC          | :yellow_heart: | Servo/ESC PWM  | `Motor::Servo`     | Works. Needs its own class.
| PCA9685              | :heart:        | I2C            | `PulseIO::PCA9685` | 16-ch, 12-bit PWM for servo or LED
| L298N                | :green_heart:  | Digi + PWM Out | `Motor::L298`      | H-Bridge DC motor driver
| DRV8833              | :heart:        | Digi + PWM Out | `Motor::DRV8833`   | H-Bridge DC motor driver
| TB6612               | :heart:        | Digi + PWM Out | `Motor::TB6612`    | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out    | `Motor::Stepper`   | 1-ch microstepper (EasyDriver)
| A4988                | :yellow_heart: | DigitalOut     | `Motor::Stepper`   | 1-ch microstepper
| TMC2209              | :heart:        | -              | -                  | 1-ch silent stepper driver

### I/O Expansion

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Input Register   | :green_heart:  | SPI        | `SPI::InputRegister` | Tested on CD4021B
| Output Register  | :green_heart:  | SPI        | `SPI::OutputRegister`| Tested on 74HC595
| PCF8574 Expander | :heart:        | I2C        | `DigitalIO::PCF8574` | 8-ch bi-directional digital I/O
| ADS1100 ADC      | :green_heart:  | I2C        | `AnalogIO::ADS1100`  | 1-ch, 16-bit ADC. No continuous mode.
| ADS1115 ADC      | :green_heart:  | I2C        | `AnalogIO::ADS1115`  | 4-ch, 16-bit ADC. Comparator not implemented.
| ADS1118 ADC      | :green_heart:  | SPI        | `AnalogIO::ADS1118`  | 4-ch, 16-bit ADC + temperature
| ADS1232 ADC      | :heart:        | SPI        | `AnalogIO::ADS1232`  | 2-ch, 24-bit ADC + temperature
| PCF8591 ADC/DAC  | :heart:        | I2C        | `AnalogIO::PCF8591`  | 4-ch, 8-bit ADC + 1-ch 8-bit DAC
| MCP4725 DAC      | :heart:        | I2C        | `AnalogIO::MCP4275`  | 1-ch, 12-bit DAC
| PCA9548 I2C Mux  | :heart:        | I2C        | `I2C::PCA9548`       | 8-way I2C multiplexer

### Environmental Sensors

| Name             | Status         | Interface   | Component Class    | Type                     | Notes                  |
| :--------------- | :------:       | :--------   | :---------------   |---------------           | ---------------------- |
| MAX31850         | :heart:        | OneWire     | `Sensor::MAX31850` | Thermocouple             |
| MAX6675          | :heart:        | SPI         | `Sensor::MAX6675`  | Thermocouple             |
| DS18B20          | :green_heart:  | OneWire     | `Sensor::DS18B20`  | Temp                     |
| DHT11/21/22      | :green_heart:  | Digi In/Out | `Sensor::DHT`      | Temp / RH                |
| SHT30/31/35      | :green_heart:  | I2C         | `Sensor::SHT3X`    | Temp / RH                | M5Stack ENV III, one-shot only
| SHT40/41         | :heart:        | I2C         | `Sensor::SHT4X`    | Temp / RH                | 
| QMP6988          | :green_heart:  | I2C         | `Sensor::QMP6988`  | Temp / Press             | M5Stack ENV III
| BMP180           | :green_heart:  | I2C         | `Sensor::BMP180`   | Temp / Press             |
| BMP280           | :green_heart:  | I2C         | `Sensor::BMP280`   | Temp / Press             |
| BME280           | :green_heart:  | I2C         | `Sensor::BME280`   | Temp / Press / RH        |
| BME680           | :heart:        | I2C         | `Sensor::BME680`   | Temp / Press / RH / TVOC |
| HTU21D           | :green_heart:  | I2C         | `Sensor::HTU21D`   | Temp / RH                | No user register read
| HTU31D           | :green_heart:  | I2C         | `Sensor::HTU31D`   | Temp / RH                | No diagnostic read
| AHT10/15         | :green_heart:  | I2C         | `Sensor::AHT10`    | Temp / RH                |
| AHT20/21/25      | :green_heart:  | I2C         | `Sensor::AHT20`    | Temp / RH                |
| ENS160           | :heart:        | I2C         | `Sensor::ENS160`   | eCO2 / TVOC / AQI        |
| AGS02MA          | :heart:        | I2C         | `Sensor::AGS02MA`  | TVOC                     |
| SCD40            | :heart:        | I2C         | `Sensor::SDC40`    | Temp / Press / CO2       |
| CCS811           | :heart:        | I2C         | `Sensor::CCS811`   | eCO2                     |

### Light Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| BH1750           | :heart:        | Digital In   | `Sensor::BH1750`   | Ambient Light
| TCS34725         | :heart:        | I2C          | `Sensor::TCS34725` | RGB
| APDS9960         | :heart:        | I2C          | `Sensor::APDS9960` | Proximity, RGB, Gesture

### PIR Motion Sensors
| Name             | Status         | Interface    | Component Class      | Notes |
| :--------------- | :------:       | :--------    | :---------------     |------ |
| HC-SR501         | :green_heart:  | Digital In   | `Sensor::GenericPIR` |
| HC-SR505         | :yellow_heart: | Digital In   | `Sensor::GenericPIR` |
| AS312            | :green_heart:  | Digital In   | `Sensor::GenericPIR` |
| AM312            | :yellow_heart: | Digital In   | `Sensor::GenericPIR` |

### Distance Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| HC-SR04          | :green_heart:  | Digi In/Out  | `Sensor::HCSR04`   | Ultrasonic, 20-4000mm
| RCWL-9620        | :green_heart:  | I2C          | `Sensor::RCWL9260` | Ultrasonic, 20-4500mm
| VL53L0X          | :heart:        | I2C          | `Sensor::VL53L0X`  | Laser, 30 - 1000mm
| GP2Y0E03         | :heart:        | I2C          | `Sensor::GP2Y0E03` | Infrared, 40 - 500mm

### Inertial Measurement Units

| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| ADXL345          | :heart:        | I2C       | `Sensor::ADXL345`  | Accelerometer
| IT3205           | :heart:        | I2C       | `Sensor::IT3205`   | Gyroscope
| HMC5883L         | :heart:        | I2C       | `Sensor::HMC5883L` | Compass
| MPU6050          | :heart:        | I2C       | `Sensor::MPU6050`  | Gyro + Accelerometer
| MPU6886          | :heart:        | I2C       | `Sensor::MPU6886`  | Gyro + Accelerometer
| BMI160           | :heart:        | I2C       | `Sensor::BMI160`   | Gyro + Accelerometer
| LSM6DS3          | :heart:        | I2C       | `Sensor:LSM6DS3`   | Gyro + Accelerometer

### Real Time Clocks

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| DS1302           | :heart:        | I2C       | `RTC::DS1302`     |
| DS1307           | :heart:        | I2C       | `RTC::DS1307`     |
| DS3231           | :green_heart:  | I2C       | `RTC::DS3231`     | Alarms not implemented
| PCF8563          | :heart:        | I2C       | `RTC::PCF8563`    |

### GPS

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| GT-U7            | :heart:        | UART      | -                 |

### Miscellaneous

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Board EEPROM     | :green_heart:  | Built-In   | `EEPROM::BuiltIn`    | Arduino ARM boards have no EEPROM
| MFRC522          | :heart:        | SPI/I2C    | `DigitalIO::MFRC522` | RFID tag reader / writer
