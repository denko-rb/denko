module Denko
  module Sensor
    class HDC1080
      include I2C::Peripheral
      include Behaviors::Poller
      include Behaviors::Lifecycle
      include TemperatureHelper
      include HumidityHelper

      I2C_ADDRESS = 0x40

      # Config Register
      CONFIG_ADDRESS = 0x02
      CONFIG_DEFAULT = 0x10
      RESET_MASK     = 0b10000000
      HEATER_MASK    = 0b00100000
      BATTERY_MASK   = 0b00001000

      # Reading registers
      TEMPERATURE_ADDRESS = 0x00
      HUMIDITY_ADDRESS    = 0x01

      def state
        @state ||= { temperature: nil, humidity: nil }
      end

      def reading
        @reading ||= { temperature: nil, humidity: nil }
      end

      after_initialize do
        reset
      end

      def reset
        @config = CONFIG_DEFAULT
        @temperature_resolution = 14
        @humidity_resolution    = 14
        write_config(@config | RESET_MASK)
        sleep 0.010
      end

      def write_config(config=@config)
        # Actually 2 bytes, but 2nd byte is reserved and 0, so ignore it.
        i2c_write [CONFIG_ADDRESS, config, 0]
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

      def battery_low?
        config = i2c_read_raw(2, register: CONFIG_ADDRESS)
        (config[0] & BATTERY_MASK) > 0
      end

      # Conversion times from datasheet, but not really used.
      TEMPERATURE_RESOLUTION_MASK = 0b00000100
      TEMPERATURE_RESOLUTIONS = {
        14 => { bits: 0b0, conversion_time: 0.007 },
        11 => { bits: 0b1, conversion_time: 0.004 },
      }

      HUMIDITY_RESOLUTION_MASK = 0b00000011
      HUMIDITY_RESOLUTIONS = {
        14 => { bits: 0b00, conversion_time: 0.007 },
        11 => { bits: 0b01, conversion_time: 0.004 },
        8  => { bits: 0b10, conversion_time: 0.003 },
      }

      attr_reader :temperature_resolution, :humidity_resolution

      def temperature_resolution=(res)
        raise ArgumentError, "wrong temperature resolution given: #{res}" unless TEMPERATURE_RESOLUTIONS.keys.include? res
        @config &= ~TEMPERATURE_RESOLUTION_MASK
        @config |= (TEMPERATURE_RESOLUTIONS[res][:bits] << 2)
        write_config
        @temperature_resolution = res
      end

      def humidity_resolution=(res)
        raise ArgumentError, "wrong humidity resolution given: #{res}" unless HUMIDITY_RESOLUTIONS.keys.include? res
        @config &= ~HUMIDITY_RESOLUTION_MASK
        @config |= HUMIDITY_RESOLUTIONS[res][:bits]
        write_config
        @humidity_resolution = res
      end

      def serial_number
        device_info[:serial_number]
      end

      def manufacturer_id
        device_info[:manufacturer_id]
      end

      def device_id
        device_info[:device_id]
      end

      def device_info
        return @device_info if @device_info

        man_id_bytes = i2c_read_raw(2, register: 0xFE)
        dev_id_bytes = i2c_read_raw(2, register: 0xFF)
        serial_l = i2c_read_raw(2, register: 0xFD)
        serial_m = i2c_read_raw(2, register: 0xFC)
        serial_h = i2c_read_raw(2, register: 0xFB)

        @device_info = {
          manufacturer_id: man_id_bytes[0] << 8 | man_id_bytes[1],
          device_id:       dev_id_bytes[0] << 8 | dev_id_bytes[1],
          serial_number:   serial_h[0] << 32 | serial_h[1] << 24 | serial_m[0] << 16 | serial_m[1] << 8 | serial_l[0],
        }
      end

      def _read
        _start_conversion
        # This is way more than given conversion times, but unreliable without.
        sleep 0.200
        _read_values
      end

      def _start_conversion
        # Writing to temperature register triggers both reads.
        i2c_write [TEMPERATURE_ADDRESS]
      end

      def _read_values
        # Read 2 bytes each for temperature and humidity.
        i2c_read(4)
      end

      def pre_callback_filter(bytes)
        raw_t = bytes[0] << 8 | bytes[1]
        raw_h = bytes[2] << 8 | bytes[3]

        reading[:temperature] = ((raw_t.to_f / 2 ** 16) * 165) - 40
        reading[:humidity]    =  (raw_h.to_f / 2 ** 16) * 100

        return nil unless (reading[:temperature] && reading[:humidity])

        reading
      end

      def update_state(reading)
        @state_mutex.lock
        @state[:temperature] = reading[:temperature]
        @state[:humidity]    = reading[:humidity]
        @state_mutex.unlock

        # Reset so pre_callback_filter can check for both values.
        reading[:temperature] = nil
        reading[:humidity]    = nil

        @state
      end
    end
  end
end
