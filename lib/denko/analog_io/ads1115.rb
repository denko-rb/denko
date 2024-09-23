module Denko
  module AnalogIO
    class ADS1115
      include I2C::Peripheral
      include ADS111X

      i2c_default_address   0x48
      i2c_default_frequency 400_000

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

      def after_initialize(options={})
        super(options)

        # Mutex and variables for BoardProxy behavior.
        @mutex        = Mutex.new
        @active_pin   = nil
        @active_gain  = nil

        # Set register bytes to default and write to device.
        @config_register = CONFIG_STARTUP.dup
        i2c_write [CONFIG_ADDRESS] + @config_register

        # Enable BoardProxy callbacks.
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

      # Readings are 2 bytes big-endian.
      def pre_callback_filter(bytes)
        bytes.pack("C*").unpack("s>")[0]
      end
    end
  end
end
