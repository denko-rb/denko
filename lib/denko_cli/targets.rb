class DenkoCLI::Generator
  STANDARD_PACKAGES = PACKAGES.each_key.map do |package|
                        package unless PACKAGES[package][:only]
                      end.compact

  TARGETS = {
    # Core is core.
    core: [:core],

    # Specific features for the old mega168 chips.
    atmega168: [:core, :tone, :i2c, :spi, :servo, :uart_bb],

    # Other ATmega chips do everything.
    # Add bit bang serial for 328p / UNO since it has no extra hardware UART.
    atmega: STANDARD_PACKAGES + [:uart_bb],

    # No tone, infrared or EEPROM on SAM3X / Due.
    atsam3x: STANDARD_PACKAGES - [:tone, :ir_out, :eeprom],

    # No EEPROM on SAMD / Zero.
    atsamd21: STANDARD_PACKAGES - [:eeprom],

    # Infrared library does not support the UNO R4.
    ra4m1: STANDARD_PACKAGES - [:ir_out],

    # ESP8266 uses an IR library specific to it.
    esp8266: STANDARD_PACKAGES,
    esp32:   STANDARD_PACKAGES,

    # RP2040 can't use WS2812 yet.
    rp2040: STANDARD_PACKAGES,
  }
end
