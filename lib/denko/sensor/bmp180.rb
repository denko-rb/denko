module Denko
  module Sensor
    class BMP180
      include Behaviors::Component
      include I2C::Peripheral
      include Behaviors::Poller
      include TemperatureHelper
      include PressureHelper

      I2C_ADDRESS = 0x77

      # Write this to register 0xE0 for soft reset
      SOFT_RESET = 0xB6

      #
      # Pressure Oversample Setting Values
      #
      # General formula:
      #   2 ** n, where n is the decimal value of the bits, up to 8x pressure oversampling.
      #
      OVERSAMPLE_FACTORS = {
        1  =>  0b00,
        2  =>  0b01,
        4  =>  0b10,
        8  =>  0b11,
      }

      after_initialize do
        # Default to start conversion off, reading temperature, no pressure oversampling.
        @register = 0b00001110
        @calibration_data_loaded = false
        @oss = 0b00

        # Temporary storage for raw bytes, since two I2C reads are needed for temperature and pressure.
        @raw_bytes = [0, 0, 0, 0, 0]

        state
        soft_reset
      end

      def state
        state_mutex.synchronize { @state ||= { temperature: nil, pressure: nil } }
      end

      def reading
        @reading ||= { temperature: nil, pressure: nil }
      end

      #
      # Configuration Methods
      #
      def soft_reset
        i2c_write(SOFT_RESET)
      end

      attr_reader :measurement_time

      def update_measurement_time
        # Get oversample bits from current register setting.
        oversample_exponent = (@register & 0b11000000) >> 6

        # Calculate time in milliseconds.
        extra_samples = (2 ** oversample_exponent) - 1
        extra_time = extra_samples * 3
        total_time = 4.5 + extra_time

        # Sleep 1ms extra for safety and convert it to seconds.
        @measurement_time = (total_time + 1) / 1000.0
      end

      def pressure_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        @oss = OVERSAMPLE_FACTORS[factor]
      end

      def write_settings
        update_measurement_time
        i2c_write [0xF4, @register]
      end

      #
      # Reading Methods
      #
      def _read_temperature
        @register = 0x2E
        write_settings
        sleep(@measurement_time)
        i2c_read(2, register: 0xF6)
      end

      def _read_pressure
        @register = 0x34 | (@oss << 6)
        write_settings
        sleep(@measurement_time)
        i2c_read(3, register: 0xF6)
      end

      # Workaround for :read callbacks getting automatically removed on first reading.
      def read(*args, **kwargs, &block)
        get_calibration_data unless calibration_data_loaded

        read_using(self.method(:_read_temperature), *args, **kwargs)
        read_using(self.method(:_read_pressure), *args, **kwargs, &block)
      end

      def _read
        get_calibration_data unless calibration_data_loaded

        _read_temperature
        _read_pressure
      end

      def pre_callback_filter(data)
        # Temperature is 2 bytes.
        if data.length == 2
          @raw_bytes[0] = data[0]
          @raw_bytes[1] = data[1]
        # Pressure is 3 bytes and triggers callbacks.
        elsif data.length == 3
          @raw_bytes[2] = data[0]
          @raw_bytes[3] = data[1]
          @raw_bytes[4] = data[2]
          return decode_reading(@raw_bytes)
        # Calibration data is 22 bytes.
        elsif data.length == 22
          process_calibration(data)
        end

        # Anything other than pressure avoids callbacks.
        return nil
      end

      def update_state(reading)
        # Checking for Hash ignores calibration data and nil.
        if reading.class == Hash
          state_mutex.synchronize do
            @state[:temperature] = reading[:temperature]
            @state[:pressure]    = reading[:pressure]
          end
        end
      end

      #
      # Decoding Methods
      #
      def decode_reading(bytes)
        temperature, b5 = decode_temperature(bytes)
        reading[:temperature] = temperature
        reading[:pressure] = decode_pressure(bytes, b5)
        reading
      end

      def decode_temperature(bytes)
        # Temperature is bytes [0..2], MSB first.
        ut = bytes[0] << 8 | bytes[1]

        # Calibration compensation from datasheet
        x1 = (ut - @calibration[:ac6]) * @calibration[:ac5] / 32768
        x2 = (@calibration[:mc] * 2048) / (x1 + @calibration[:md])
        b5 = x1 + x2

        # 160 instead of 16 since datasheet calculates to 0.1 C units.
        # Float to force the final value into float, but keep b5 integer for pressure.
        temperature = (b5 + 8) / 160.0

        # Return temperature and b5 for pressure calculation.
        [temperature, b5]
      end

      def decode_pressure(bytes, b5)
        # Pressure is bytes [2..3], MSB first.
        up = ((bytes[2] << 16) | (bytes[3] << 8) | (bytes[4])) >> (8 - @oss)

        # Calibration compensation from datasheet
        b6 = b5 - 4000
        x1 = (@calibration[:b2] * (b6 * b6 / 4096)) / 2048
        x2 = @calibration[:ac2] * b6 / 2048
        x3 = x1 + x2
        b3 = (((@calibration[:ac1]*4 + x3) << @oss) + 2) / 4
        x1 = @calibration[:ac3] * b6 / 8192
        x2 = (@calibration[:b1] * (b6 * b6 / 4096)) / 65536
        x3 = (x1 + x2 + 2) / 4
        b4 = (@calibration[:ac4] * ((x3+32768) & 0xFFFF_FFFF)) / 32768
        b7 = ((up & 0xFFFF_FFFF) - b3) * (50000 >> @oss)
        if (b7 < 0x8000_0000)
          p = (b7 * 2) / b4
        else
          p = (b7 / b4) * 2
        end
        x1 = (p / 256) * (p / 256)
        x1 = (x1 * 3038) / 65536
        x2 = (-7357 * p) / 65536
        p = p + (x1 + x2 + 3791) / 16
        pressure = p.to_f
      end

      #
      # Calibration Methods
      #
      attr_reader :calibration_data_loaded

      def get_calibration_data
        #  Calibration data is 22 bytes starting at address 0xAA.
        read_using -> { i2c_read(22, register: 0xAA) }
      end

      def process_calibration(bytes)
        if bytes
          @calibration = {
            ac1: bytes[0..1].pack('C*').unpack('s>')[0],
            ac2: bytes[2..3].pack('C*').unpack('s>')[0],
            ac3: bytes[4..5].pack('C*').unpack('s>')[0],
            ac4: bytes[6..7].pack('C*').unpack('S>')[0],
            ac5: bytes[8..9].pack('C*').unpack('S>')[0],
            ac6: bytes[10..11].pack('C*').unpack('S>')[0],
            b1: bytes[12..13].pack('C*').unpack('s>')[0],
            b2: bytes[14..15].pack('C*').unpack('s>')[0],
            mb: bytes[16..17].pack('C*').unpack('s>')[0],
            mc: bytes[18..19].pack('C*').unpack('s>')[0],
            md: bytes[20..21].pack('C*').unpack('s>')[0],
          }
          @calibration_data_loaded = true
        end
      end
    end
  end
end
