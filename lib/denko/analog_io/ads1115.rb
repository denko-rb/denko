module Denko
  module AnalogIO
    class ADS1115
      include Behaviors::Lifecycle
      include I2C::Peripheral
      include ADS111X

      I2C_ADDRESS   = 0x48
      I2C_FREQUENCY = 400_000

      # Config register values on startup. MSB-first.
      # Matches datasheet, except MSB bit 7 unset to avoid conversion start.
      # Same as: [0x05, 0x83] or [5, 131]
      CONFIG_STARTUP = [0b00000101, 0b10000011]

      # Base config bytes to mask settings into. Not same as startup config.
      # MSB bits 0 and 7 set to enable single-shot mode.
      # LSB bits 0 and 1 set to disable comparator.
      BASE_MSB = 0b10000001
      BASE_LSB = 0b00000011

      # Register addresses.
      CONFIG_ADDRESS     = 0b01
      CONVERSION_ADDRESS = 0b00

      after_initialize do
        # Set register bytes to default and write to device.
        i2c_write [CONFIG_ADDRESS] + config_register
        enable_proxy
      end

      def _read(config)
        # Write config register to start reading.
        i2c_write [CONFIG_ADDRESS] + config

        # Sleep the right amount of time for conversion, based on sample rate bits.
        sleep WAIT_TIMES[config[1] >> 5]

        # Read the result, triggering callbacks.
        i2c_read(2, register: CONVERSION_ADDRESS)
      end
    end
  end
end
