module Denko
  module AnalogIO
    class ADS1118
      include SPI::Peripheral::SinglePin
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

      def after_initialize(options={})
        super(options)

        # SPI mode 1 recommended.
        @spi_mode = options[:spi_mode] || 1

        # Mutex and variables for BoardProxy behavior.
        @mutex        = Mutex.new
        @active_pin   = nil
        @active_gain  = nil

        # Set register bytes to default and write to device.
        @config_register = CONFIG_STARTUP.dup
        spi_write(@config_register)

        # Enable BoardProxy callbacks.
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

      # Pack the 2 bytes back into a string, then unpack as big-endian signed int16.
      def pre_callback_filter(message)
        bytes = message.split(",").map { |b| b.to_i }
        bytes.pack("C*").unpack("s>")[0]
      end

      def _temperature_read
        # Wrap in mutex to not interfere with other reads.
        @mutex.synchronize do
          _read([0b10000001, 0b10011011])
        end
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
