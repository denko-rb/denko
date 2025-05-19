module Denko
  module AnalogIO
    class ADS1118
      include SPI::Peripheral
      include Behaviors::Lifecycle
      include ADS111X

      # Config register values on startup. MSB-first.
      # Matches datasheet. Same as: [0x05, 0x8B] or [5, 139]
      CONFIG_STARTUP = [0b00000101, 0b10001011]

      # Base config bytes to mask settings into. Not same as default.
      # MSB bits 0 and 7 set to enable single-shot mode.
      # LSB bit 3 set to enable pullup resistor on MISO pin.
      # LSB bit 1 set to flag valid data in the NOP bits.
      BASE_MSB = 0b10000001
      BASE_LSB = 0b00001010

      def spi_mode
        @spi_mode ||= params[:spi_mode] || 1
      end

      after_initialize do
        spi_write(config_register)
        enable_proxy
      end

      def _read(config)
        # Write config register to start reading.
        spi_write(config)

        # Sleep the right amount of time for conversion, based on sample rate bits.
        sleep WAIT_TIMES[config[1] >> 5]

        # Read the result, triggering callbacks.
        spi_read(2)
      end

      def _temperature_read
        # Don't interfere with subcomponent reads.
        mutex.lock
        _read([0b10000001, 0b10011011])
        mutex.unlock
      end

      def temperature_read(&block)
        reading = read_using -> { _temperature_read }

        # Temperature is shifted 2 bits left, and is 0.03125 degrees C per bit.
        temperature = (reading / 4) * 0.03125

        block.call(temperature) if block_given?
        return temperature
      end
    end
  end
end
