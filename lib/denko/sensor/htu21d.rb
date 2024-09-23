module Denko
  module Sensor
    class HTU21D
      include I2C::Peripheral
      include Behaviors::Poller
      include TemperatureHelper

      I2C_ADDRESS = 0x40

      # Commands
      SOFT_RESET                = 0xFE
      WRITE_CONFIG              = 0xE6
      READ_TEMPERATURE_BLOCKING = 0xE3
      READ_HUMIDITY_BLOCKING    = 0xE5

      # Config values
      CONFIG_DEFAULT            = 0b00000011
      HEATER_MASK               = 0b00000100
      RESOLUTION_MASK           = 0b10000001

      def after_initialize(options={})
        super(options)
        @config = CONFIG_DEFAULT
        reset
        heater_off
      end

      def state
        state_mutex.synchronize { @state = { temperature: nil, humidity: nil } }
      end

      def reading
        @reading ||= { temperature: nil, humidity: nil }
      end

      def reset
        i2c_write [SOFT_RESET]
        sleep 0.015
      end

      def write_config
        i2c_write [WRITE_CONFIG, @config]
      end

      def heater_on?
        (@config & HEATER_MASK) > 0
      end

      def heater_off?
        !heater_on?
      end

      def heater_on
        @config |= HEATER_MASK
        write_config
      end

      def heater_off
        @config &= ~HEATER_MASK
        write_config
      end

      #
      # Only 4 resolution combinations are available.
      # Set by giving a bitmask from the datasheet:
      #
      RESOLUTIONS = {
        0x00 => {temperature: 14, humidity: 12},
        0x01 => {temperature: 12, humidity: 8},
        0x80 => {temperature: 13, humidity: 10},
        0x81 => {temperature: 11, humidity: 11},
      }

      def resolution=(setting)
        raise ArgumentError, "wrong resolution setting given: #{mask}" unless RESOLUTIONS.keys.include? setting
        @config &= ~RESOLUTION_MASK
        @config |= setting
        write_config
      end

      def resolution
        resolution_bits = @config & RESOLUTION_MASK
        raise StandardError, "cannot get resolution from config register: #{@config}" unless RESOLUTIONS[resolution_bits]
        RESOLUTIONS[resolution_bits]
      end

      # Workaround for :read callbacks getting automatically removed on first reading.
      def read(*args, **kwargs, &block)
        read_using(self.method(:_read_temperature), *args, **kwargs)
        read_using(self.method(:_read_humidity), *args, **kwargs, &block)
      end

      def _read
        _read_temperature
        _read_humidity
      end

      def _read_temperature
        i2c_read(3, register: READ_TEMPERATURE_BLOCKING)
      end

      def _read_humidity
        i2c_read(3, register: READ_HUMIDITY_BLOCKING)
      end

      def pre_callback_filter(bytes)
        # Raw value is first 2 bytes big-endian.
        raw_value = (bytes[0] << 8) | bytes[1]
        return { error: 'CRC failure' } unless calculate_crc(raw_value) == bytes[2]

        # Lowest 2 bits must be zeroed before conversion.
        raw_value = raw_value & 0xFFFC

        # Bit 1 of LS byte determines type of reading; 0 for temperature, 1 for humidity.
        if (bytes[1] & 0b00000010) > 0
          # Calculate humidity and limit within 0-100 range.
          humidity = (raw_value.to_f / 524.288) - 6
          humidity = 0.0   if humidity < 0.0
          humidity = 100.0 if humidity > 100.0
          reading[:humidity] = humidity
        else
          reading[:temperature] = (175.72 * raw_value.to_f / 65536) - 46.8
        end

        # Wait for both values to be read.
        return nil unless (reading[:temperature] && reading[:humidity])

        reading
      end

      def update_state(reading)
        state_mutex.synchronize do
          @state[:temperature] = reading[:temperature]
          @state[:humidity]    = reading[:humidity]
        end
        # Reset so pre_callback_filter can check for both values.
        reading = { temperature: nil, humidity: nil }
      end

      #
      # CRC calculation adapted from offical driver, found here:
      # https://github.com/TEConnectivity/HTU21D_Generic_C_Driver/blob/master/htu21d.c#L275
      #
      def calculate_crc(value)
        polynomial = 0x988000   # x^8 + x^5 + x^4 + 1
        msb        = 0x800000
        mask       = 0xFF8000
        result     = value << 8 # Pad right with length of output CRC

        while msb != 0x80
          result = ((result ^ polynomial) & mask) | (result & ~mask) if (result & msb !=0)
          msb        >>= 1
          mask       >>= 1
          polynomial >>= 1
        end
        result
      end
    end
  end
end
