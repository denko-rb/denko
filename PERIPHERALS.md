# Supported Peripherals

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

## Digital and Analog Input and Output

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Button           | :green_heart:  | Digital In   | `DigitalIO::Button`        |
| Relay            | :green_heart:  | Digital Out  | `DigitalIO::Relay`         |
| Rotary Encoder   | :green_heart:  | Digital In   | `DigitalIO::RotaryEncoder` | Listens every 1ms
| Potentiometer    | :green_heart:  | Analog In    | `AnalogIO::Potentiometer`  | Smoothing on by default
| Joystick         | :green_heart:  | Analog In    | `AnalogIO::Joystick`       |

## LED

| Name               | Status             | Interface         | Component Class       | Notes |
| :---------------   | :------:           | :--------         | :---------------      |------ |
| LED                | :green_heart:      | Digi/Ana Out      | `LED::Base`           |
| RGB LED            | :green_heart:      | Digi/Ana Out      | `LED::RGB`            |
| Seven Segment      | :green_heart:      | Digital Out       | `LED::SevenSegment`   | Bit 7 can be decimal point **OR** colon
| Seven Segment SPI  | :green_heart:      | SPI               | `LED::SevenSegmentSPI`| Multiple SevenSegment thru 595 registers
| MAX7219            | :heart:            | SPI               | `LED::MAX7219`        | 8x 7-Segment w/DP **OR** 8x8 matrix
| TM1637             | :green_heart:      | Digi Out Bit-Bang | `LED::TM1637`         | 4x 7-Segment + colon. Inputs ignored
| TM1638             | :yellow_heart:     | SPI Bit-Bang      | `LED::TM1638`         | 8x 7-Segment w/ DP + 8 LEDs. No inputs yet
| TM1652             | :green_heart:      | UART Hardware     | `LED::TM1652`         | 4x 7-Segment, 3 w/DP, 1 with colon
| WS2812 (Neopixel)  | :green_heart:      | Adafruit Library  | `LED::WS2812`         |
| APA102 (Dotstar)   | :green_heart:      | SPI               | `LED::APA102`         |

## Display

| Name                | Status         | Interface                    | Component Class     | Notes |
| :---------------    | :------:       | :--------                    | :---------------    |------ |
| HD44780 LCD         | :green_heart:  | Digital Out, Output Register | `Display::HD44780`  | Char LCD. Also works through PCF8574
| Canvas              | :yellow_heart: | -                            | `Display::Canvas`   | Mono 2D graphics
| SSD1306             | :green_heart:  | I2C or SPI                   | `Display::SSD1306`  | Mono OLED: 128x64, 128x32
| SH1106              | :green_heart:  | I2C or SPI                   | `Display::SH1106`   | Mono OLED: 128x64
| SH1107              | :green_heart:  | I2C or SPI                   | `Display::SH1107`   | Mono OLED: 128x128
| PCD8544             | :green_heart:  | SPI                          | `Display::PCD8544`  | 84x48 Mono LCD (aka Nokia 5110)
| ST7565              | :green_heart:  | SPI                          | `Display::ST7565`   | 128x64 Mono LCD
| ST7302              | :green_heart:  | SPI                          | `Display::ST7302`   | 250x122 Mono Reflective LCD
| LS027B7DH01         | :heart:        | SPI                          | `Display::SharpLCD` | 400x240 Mono Reflective LCD
| SSD1680             | :green_heart:  | SPI                          | `Display::SSD1680`  | 296x128 Black/(Red)/White E-Paper (2.9")
| SSD1681             | :green_heart:  | SPI                          | `Display::SSD1681`  | 200x200 Black/(Red)/White E-Paper (1.54")
| IL0373              | :green_heart:  | SPI                          | `Display::IL0373`   | 212x104 Black/(Red)/White E-Paper (2.13")
| ST7735S             | :heart:        | SPI                          | `Display::ST7735S`  | 160x128 RGB LCD
| ST7789V             | :heart:        | SPI                          | `Display::ST7789V`  | 240x135 RGB LCD (TTGO)
| ILI9341             | :heart:        | SPI                          | `Display::ILI9341`  | 240x320 RGB LCD
| GC9107              | :heart:        | SPI                          | `Display::GC9107`   | 128x128 RGB LCD
| GC9A01              | :heart:        | SPI                          | `Display::GCA9A01`  | 240x240 Round RGB LCD

## Sound

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Piezo Buzzer     | :green_heart:  | Tone Out     | `PulseIO::Buzzer`          | Frequency > 30Hz

## Motors and Motor Drivers

| Name                 | Status         | Interface      | Component Class    | Notes |
| :---------------     | :------:       | :--------      | :---------------   |------ |
| Generic Hobby Servo  | :green_heart:  | Servo/ESC PWM  | `Motor::Servo`     | Max depends on PWM channel count
| Generic ESC          | :yellow_heart: | Servo/ESC PWM  | `Motor::Servo`     | Works. Needs its own class.
| PCA9685              | :heart:        | I2C            | `PulseIO::PCA9685` | 16-ch, 12-bit PWM for servo or LED
| L298N                | :green_heart:  | Digi + PWM Out | `Motor::L298`      | H-Bridge DC motor driver
| DRV8833              | :heart:        | Digi + PWM Out | `Motor::DRV8833`   | H-Bridge DC motor driver
| TB6612               | :heart:        | Digi + PWM Out | `Motor::TB6612`    | H-Bridge DC motor driver
| AT8236               | :heart:        | Digi + PWM Out | `Motor::AT8236`    | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out    | `Motor::A3967`     | 1-ch microstepper (EasyDriver)
| A4988                | :yellow_heart: | DigitalOut     | `Motor::Stepper`   | 1-ch microstepper
| TMC2209              | :heart:        | -              | -                  | 1-ch silent stepper driver

## I/O Expansion

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Input Register   | :green_heart:  | SPI        | `SPI::InputRegister` | Tested on CD4021B
| Output Register  | :green_heart:  | SPI        | `SPI::OutputRegister`| Tested on 74HC595
| PCF8574 Expander | :green_heart:  | I2C        | `DigitalIO::PCF8574` | 8-ch digital I/O. Commonly found on HD44780
| ADS1100 ADC      | :green_heart:  | I2C        | `AnalogIO::ADS1100`  | 1-ch, 16-bit ADC. No continuous mode.
| ADS1115 ADC      | :green_heart:  | I2C        | `AnalogIO::ADS1115`  | 4-ch, 16-bit ADC. Comparator not implemented.
| ADS1118 ADC      | :green_heart:  | SPI        | `AnalogIO::ADS1118`  | 4-ch, 16-bit ADC + temperature
| ADS1232 ADC      | :heart:        | SPI        | `AnalogIO::ADS1232`  | 2-ch, 24-bit ADC + temperature
| PCF8591 ADC/DAC  | :heart:        | I2C        | `AnalogIO::PCF8591`  | 4-ch, 8-bit ADC + 1-ch 8-bit DAC
| MCP4725 DAC      | :heart:        | I2C        | `AnalogIO::MCP4275`  | 1-ch, 12-bit DAC
| PCA9548 I2C Mux  | :heart:        | I2C        | `I2C::PCA9548`       | 8-way I2C multiplexer

## Environmental Sensors

| Name             | Status         | Interface   | Component Class    | Type                     | Notes                  |
| :--------------- | :------:       | :--------   | :---------------   |---------------           | ---------------------- |
| MAX31850         | :heart:        | OneWire     | `Sensor::MAX31850` | Thermocouple             |
| MAX6675          | :heart:        | SPI         | `Sensor::MAX6675`  | Thermocouple             |
| DS18B20          | :green_heart:  | OneWire     | `Sensor::DS18B20`  | Temp                     |
| DHT11/21/22      | :green_heart:  | Digi In/Out | `Sensor::DHT`      | Temp / RH                |
| SHT30/31/35      | :green_heart:  | I2C         | `Sensor::SHT3X`    | Temp / RH                | M5Stack ENV III, one-shot only
| SHT40/41         | :green_heart:  | I2C         | `Sensor::SHT4X`    | Temp / RH                |
| QMP6988          | :green_heart:  | I2C         | `Sensor::QMP6988`  | Temp / Press             | M5Stack ENV III
| BMP180           | :green_heart:  | I2C         | `Sensor::BMP180`   | Temp / Press             |
| BMP280           | :green_heart:  | I2C         | `Sensor::BMP280`   | Temp / Press             |
| BME280           | :green_heart:  | I2C         | `Sensor::BME280`   | Temp / Press / RH        |
| BME680           | :heart:        | I2C         | `Sensor::BME680`   | Temp / Press / RH / TVOC |
| HDC1080          | :green_heart:  | I2C         | `Sensor::HDC1080`  | Temp / RH                |
| HTU21D           | :green_heart:  | I2C         | `Sensor::HTU21D`   | Temp / RH                | No user register read
| HTU31D           | :green_heart:  | I2C         | `Sensor::HTU31D`   | Temp / RH                | No diagnostic read
| AHT10/15         | :green_heart:  | I2C         | `Sensor::AHT1X`    | Temp / RH                |
| AHT20/21/25      | :green_heart:  | I2C         | `Sensor::AHT2X`    | Temp / RH                |
| AHT30            | :green_heart:  | I2C         | `Sensor::AHT3X`    | Temp / RH                |
| ENS160           | :heart:        | I2C         | `Sensor::ENS160`   | eCO2 / TVOC / AQI        |
| AGS02MA          | :heart:        | I2C         | `Sensor::AGS02MA`  | TVOC                     |
| SCD40            | :heart:        | I2C         | `Sensor::SDC40`    | Temp / Press / CO2       |
| CCS811           | :heart:        | I2C         | `Sensor::CCS811`   | eCO2                     |
| MICS5524         | :heart:        | Analog In   | `Sensor::MICS5524` | CO/Alcohol/VOC           |

## Light Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| BH1750           | :heart:        | Digital In   | `Sensor::BH1750`   | Ambient Light
| TCS34725         | :heart:        | I2C          | `Sensor::TCS34725` | RGB
| APDS9960         | :heart:        | I2C          | `Sensor::APDS9960` | Proximity, RGB, Gesture

## PIR Motion Sensors
| Name             | Status         | Interface    | Component Class      | Notes |
| :--------------- | :------:       | :--------    | :---------------     |------ |
| HC-SR501         | :green_heart:  | Digital In   | `Sensor::GenericPIR` |
| HC-SR505         | :yellow_heart: | Digital In   | `Sensor::GenericPIR` |
| AS312            | :green_heart:  | Digital In   | `Sensor::GenericPIR` |
| AM312            | :yellow_heart: | Digital In   | `Sensor::GenericPIR` |

## Distance Sensors

| Name             | Status         | Interface    | Component Class    | Notes |
| :--------------- | :------:       | :--------    | :---------------   |------ |
| HC-SR04          | :green_heart:  | Digi In/Out  | `Sensor::HCSR04`   | Ultrasonic, 20-4000mm
| RCWL-1601        | :green_heart:  | Digi In/Out  | `Sensor::HCSR04`   | Essentially a 3.3V version of HC-SR04
| RCWL-9620        | :green_heart:  | I2C          | `Sensor::RCWL9260` | Ultrasonic, 20-4500mm
| JSN-SR04T        | :green_heart:  | UART         | `Sensor::JSNSR04T` | Mode 2 ONLY. Use HC-SR04 driver for mode 0 or 4.
| VL53L0X          | :yellow_heart: | I2C          | `Sensor::VL53L0X`  | Laser, 20 - 2000mm. Continuous mode only. No configuration.
| GP2Y0E03         | :heart:        | I2C          | `Sensor::GP2Y0E03` | Infrared, 40 - 500mm

## Inertial Measurement Units

| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| ADXL345          | :heart:        | I2C       | `Sensor::ADXL345`  | Accelerometer
| IT3205           | :heart:        | I2C       | `Sensor::IT3205`   | Gyroscope
| HMC5883L         | :heart:        | I2C       | `Sensor::HMC5883L` | Compass
| MPU6050          | :heart:        | I2C       | `Sensor::MPU6050`  | Gyro + Accelerometer
| MPU6886          | :heart:        | I2C       | `Sensor::MPU6886`  | Gyro + Accelerometer
| BMI160           | :heart:        | I2C       | `Sensor::BMI160`   | Gyro + Accelerometer
| LSM6DS3          | :heart:        | I2C       | `Sensor:LSM6DS3`   | Gyro + Accelerometer

## Misc Sensors
| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| INA219           | :heart:        | I2C       | `Sensor::INA219`   | DC Current Sensor

## Real Time Clocks

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| DS1302           | :heart:        | I2C       | `RTC::DS1302`     |
| DS1307           | :heart:        | I2C       | `RTC::DS1307`     |
| DS3231           | :green_heart:  | I2C       | `RTC::DS3231`     | Alarms not implemented
| PCF8563          | :heart:        | I2C       | `RTC::PCF8563`    |

## GPS

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| GT-U7            | :heart:        | UART      | -                 |

## Miscellaneous

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| Board EEPROM     | :green_heart:  | Built-In   | `EEPROM::Board`      | Arduino ARM boards have no EEPROM
| AT24C            | :green_heart:  | I2C        | `EEPROM::AT24C`      | I2C EEPROM (32, 64, 128 or 256 kib)
| MFRC522          | :heart:        | SPI/I2C    | `DigitalIO::MFRC522` | RFID tag reader / writer
