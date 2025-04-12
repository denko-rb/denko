module Denko
  module Sensor
    class SHT4X
      include I2C::Peripheral
      include Behaviors::Poller
      include Behaviors::Lifecycle
      include TemperatureHelper
      include HumidityHelper

      I2C_ADDRESS = 0x44

      RESET       = 0x94
      RESET_TIME  = 0.001
      READ_SERIAL_NUMBER = 0x89

      REPEATABILITIES = {
        high:   {command: 0xFD, time: 0.010},
        medium: {command: 0xF6, time: 0.005},
        low:    {command: 0xE0, time: 0.003},
      }

      after_initialize do
        reset
        self.repeatability = :high
      end

      def state
        @state ||= { temperature: nil, humidity: nil }
      end

      def reading
        @reading ||= { temperature: nil, humidity: nil }
      end

      def repeatability=(key)
        raise ArgumentError, "invalid repeatability setting: #{key}" unless REPEATABILITIES.keys.include? key
        @measurement_command = REPEATABILITIES[key][:command]
        @measurement_time = REPEATABILITIES[key][:time]
      end

      def _read
        i2c_write [@measurement_command]
        sleep(@measurement_time)
        i2c_read(6)
      end

      def pre_callback_filter(bytes)
        # Temperature is bytes 0 to 2: MSB, LSB, CRC
        if calculate_crc(bytes[0..2]) == bytes[2]
          t_raw = (bytes[0] << 8) | bytes[1]
          reading[:temperature] = (175 * t_raw / 65535.0) - 45
        else
          reading[:temperature] = nil
        end

        # Humidity is bytes 3 to 5: MSB, LSB, CRC
        if calculate_crc(bytes[3..5]) == bytes[5]
          h_raw = (bytes[3] << 8) | bytes[4]
          reading[:humidity] = 100 * h_raw / 65535.0
        else
          reading[:humidity] = nil
        end

        reading
      end

      def update_state(reading)
        @state_mutex.lock
        @state[:temperature] = reading[:temperature]
        @state[:humidity]    = reading[:humidity]
        @state_mutex.unlock
        @state
      end

      def reset
        i2c_write [RESET]
        sleep RESET_TIME
      end

      def serial
        @serial ||= read_serial
      end

      def read_serial
        i2c_write [READ_SERIAL_NUMBER]
        sleep RESET_TIME
        bytes = i2c_read_raw(6)
        parse_serial(bytes)
      end

      def parse_serial(bytes)
        # Serial bytes are laid out as [b0, b1, crc0+1, b2, b3, crc2+3]
        if calculate_crc(bytes[0..2]) == bytes[2] && calculate_crc(bytes[3..5]) == bytes[5]
          @serial = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[3] << 8) | bytes[4]
        else
          @serial = nil
        end
      end

      # CRC is same as AHT20 sensor. Copied from that file.
      CRC_INITIAL_VALUE = 0xFF
      CRC_POLYNOMIAL    = 0x31
      MSBIT_MASK        = 0x80

      def calculate_crc(bytes)
        crc = CRC_INITIAL_VALUE

        # Ignore last byte. That's the CRC value to compare with.
        bytes.take(bytes.length - 1).each do |byte|
          crc = crc ^ byte
          8.times do
            if (crc & MSBIT_MASK) > 0
              crc = (crc << 1) ^ CRC_POLYNOMIAL
            else
              crc = crc << 1
            end
          end
        end

        # Limit CRC size to 8 bits.
        crc = crc & 0xFF
      end
    end
  end
end
