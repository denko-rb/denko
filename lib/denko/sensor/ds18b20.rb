module Denko
  module Sensor
    class DS18B20 < OneWire::Peripheral
      include Behaviors::Lifecycle
      include TemperatureHelper
      FAMILY_CODE = 0x28

      after_initialize do
        @state    = { temperature: nil }
        @reading  = { temperature: nil }
      end

      def _read
        convert
        read_scratch(9) { |data| self.update(data) }
      end

      def convert
        set_convert_time

        atomically do
          match
          bus.write(CONVERT_T)
          sleep @convert_time if bus.parasite_power
        end
        sleep @convert_time unless bus.parasite_power
      end

      def set_convert_time
        @convert_time = 0.75 / (2 ** (12 - (@resolution || 12)))
      end

      def pre_callback_filter(bytes)
        return { crc_error: true } unless OneWire::Helper.crc(bytes)

        @resolution ||= decode_resolution(bytes)
        @reading[:temperature] = decode_temperature(bytes)

        @reading
      end

      def update_state(hash)
        @state[:temperature] = hash[:temperature]
        @state
      end

      def decode_resolution(bytes)
        config_byte = bytes[4]
        offset = config_byte >> 5
        offset + 9
      end

      #
      # Temperature is the first 16 bits (2 bytes of 9 read).
      # It's a signed, 2's complement, little-endian decimal. LSB = 2 ^ -4.
      #
      def decode_temperature(bytes)
        bytes[0..1].pack('C*').unpack('s<')[0] * (2.0 ** -4)
      end

      attr_reader :resolution

      def resolution=(bits)
        unless (9..12).include?(bits)
          raise ArgumentError, 'Invalid DS18B20 resolution, expected 9 to 12'
        end

        eeprom = read_scratch(9)[2..4]
        eeprom[2] = 0b00011111 | ((bits - 9) << 5)
        write_scratch(eeprom)
        copy_scratch
        @resolution = bits
      end
    end
  end
end
