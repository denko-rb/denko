### Install Arduino Dependencies for Denko (IDE)

### Installing Cores

Some microcontroller platforms require board manager cores that do not come with the IDE. To install a core:
  * Open the Preferences window of the IDE, and find "Additional boards manager URLS:". Click the button next to it.
  * In the editor that opens, paste the given URL on a new line at the end (if it doesn't already exist).
  * Confirm and exit Preferences. Wait for the IDE to finish downloading indexes from the new URL.
  * Click on Tools > Board > Board Manager.
  * Search for the platform you are installing by name, and click Install, optionally selecting a version.

### Installing Libraries

All platforms will require libraries to be installed. To install a library do the following:
  * Click on Tools > Manage Libraries.
  * Search for the library you are installing by name, and click Install, optionally selecting a version.

### Platforms:

**Note:** Always install the latest version of a package unless its version number is specified

**Install Everything:**
  * Board Manager URLs:
    ````
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
    ````
  * Boards:
    ````
    Arduino megaAVR Boards
    Arduino SAM Boards (32-bits ARM Cortex-M3)
    Arduino SAMD Boards (32-bits ARM Cortex-M0+)
    Arduino UNO R4 Boards
    ESP8266 Boards
    ESP32 Boards @ v3.0.5
    Raspberry Pi Pico/RP2040
    ````
  * Libraries:
    ````
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    WiFi101                    by Arduino
    WiFiNINA                   by Arduino
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    ESP32Servo                 by Kevin Harrington, John K. Bennett
    Adafruit NeoPixel          by Adafruit
    ````

**AVR-based Arduinos & Clones Only:**
  * Boards:
    ````
    Arduino megaAVR Boards (only for Atmega4809 / Nano Every)
    ````
  * Libraries:
    ````
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    WiFiNINA                   by Arduino
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    Adafruit NeoPixel          by Adafruit
    ````

**ARM-based Arduinos & Clones Only:**
  * Boards:
    ````
    Arduino SAM Boards (32-bits ARM Cortex-M3)
    Arduino SAMD Boards (32-bits ARM Cortex-M0+)
    Arduino UNO R4 Boards
    ````
  * Libraries:
    ````
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    WiFi101                    by Arduino
    WiFiNINA                   by Arduino
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    Adafruit NeoPixel          by Adafruit
    ````

**ESP8266 Only:**
  * Board Manager URLs:
    ````
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    ````
  * Boards:
    ````
    ESP8266 Boards
    ````
  * Libraries:
    ````
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    Adafruit NeoPixel          by Adafruit
    ````

**ESP32 Only:**
  * Board Manager URLs:
    ````
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    ````
  * Boards (latest version unless specified):
    ````
    ESP32 Boards @ v3.0.5
    ````
  * Libraries (latest version unless specified):
    ````
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    ESP32Servo                 by Kevin Harrington, John K. Bennett
    Adafruit NeoPixel          by Adafruit
    ````

**RP2040 Only:**
  * Board Manager URLs:
    ````
    https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
    ````
  * Boards:
    ````
    Raspberry Pi Pico/RP2040
    ````
  * Libraries:
    ````
    IRremote         @ v4.4.1  by shirriff, z3to, ArminJo
    ````
