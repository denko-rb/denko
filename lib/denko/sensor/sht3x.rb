module Denko
  module Sensor
    class SHT3X
      include I2C::Peripheral
      include Behaviors::Poller
      include Behaviors::Lifecycle
      include TemperatureHelper
      include HumidityHelper

      I2C_ADDRESS   = 0x44

      RESET                 = 0x30A2
      RESET_TIME            = 0.002
      HEATER_OFF            = 0x3066
      HEATER_ON             = 0x306D
      FETCH_DATA            = 0xE000
      REPEATABILITY         = {
        high:   { lsb: 0x00, measurement_time: 0.016 },
        medium: { lsb: 0x0B, measurement_time: 0.007 },
        low:    { lsb: 0x16, measurement_time: 0.005 },
      }

      # Unused
      READ_STATUS_REGISTER  = 0xF32D
      CLEAR_STATUS_REGISTER = 0x3041
      BREAK                 = 0x3093
      ART                   = 0x2B32

      after_initialize do
        reset
        self.repeatability = :high
      end

      def state
        @state ||= { temperature: nil, humidity: nil } }
      end

      def reading
        @reading ||= { temperature: nil, humidity: nil }
      end

      def repeatability=(key)
        raise ArgumentError, "invalid repeatability setting: #{key}" unless REPEATABILITY.keys.include? key
        @measurement_lsb = REPEATABILITY[key][:lsb]
        @measurement_time = REPEATABILITY[key][:measurement_time]
      end

      def _read
        i2c_write [0x24, @measurement_lsb]
        sleep(@measurement_time)
        i2c_read(6, register: FETCH_DATA)
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
        state_mutex.synchronize do
          @state[:temperature] = reading[:temperature]
          @state[:humidity]    = reading[:humidity]
        end
      end

      def reset
        i2c_write [RESET]
        sleep RESET_TIME
        @heater_on = false
      end

      def heater_on?
        @heater_on
      end

      def heater_off?
        !@heater_on
      end

      def heater_on
        i2c_write [HEATER_ON]
        @heater_on = true
      end

      def heater_off
        i2c_write [HEATER_OFF]
        @heater_on = false
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
