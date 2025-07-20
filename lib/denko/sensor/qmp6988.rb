module Denko
  module Sensor
    class QMP6988
      include Behaviors::Lifecycle
      include I2C::Peripheral
      include Behaviors::Poller
      include TemperatureHelper
      include PressureHelper

      I2C_ADDRESS = 0x70

      UPDATE_TIME           = 0.020
      RESET_REGISTER        = 0xE0
      RESET_COMMAND         = 0xE6
      CTRL_MEAS_REGISTER    = 0xF4
      STANDBY_TIME_REGISTER = 0xF5
      IIR_REGISTER          = 0xF1
      CONFIG_LENGTH         = 5
      DATA_REGISTER         = 0xF7
      DATA_LENGTH           = 6
      CALIBRATION_REGISTER  = 0xA0
      CALIBRATION_LENGTH    = 25
      CHIP_ID_REGISTER      = 0xD1
      CHIP_ID_LENGTH        = 1
      FORCED_MODE           = 0b01
      NORMAL_MODE           = 0b11

      # Standby Times for Normal (Continuous) Mode in milliseconds
      STANDBY_TIMES = {
        1    => 0b000,
        5    => 0b001,
        50   => 0b010,
        250  => 0b011,
        500  => 0b100,
        1000 => 0b101,
        2000 => 0b110,
        4000 => 0b111,
      }

      #
      # Oversample Setting Values
      # Note: Each sensor has a separate oversample setting.
      #
      # General formula:
      #   2 ** (n-1), where n is the decimal value of the bits, up to 16x max oversampling.
      #
      OVERSAMPLE_FACTORS = {
        # 0  =>  0b000, # Sensor skipped. Value will be 0x800000.
        1  =>  0b001,
        2  =>  0b010,
        4  =>  0b011,
        8  =>  0b100,
        16 =>  0b101,
        32 =>  0b110,
        64 =>  0b111,
      }
      #
      # Single sample times (in milliseconds) for each sensor, derived from datasheet examples.
      TEMPERATURE_SAMPLE_TIME = 0.9
      PRESSURE_SAMPLE_TIME = 0.85

      # IIR Filter Coefficients
      IIR_COEFFICIENTS = {
        0  =>  0b000,
        2  =>  0b001,
        4  =>  0b010,
        8  =>  0b011,
        16 =>  0b100,
        32 =>  0b101, # 0b110 and 0b111 are also valid for 16.
      }

      after_initialize do
        @state    = { temperature: nil, pressure: nil }
        @reading  = { temperature: nil, pressure: nil }

        reset
        # Get 5 config registers. Copy 0xF4 to modify it for control.
        get_config_registers
        @ctrl_meas_register = @registers[:f4].dup

        # Default settings
        self.iir_coefficient = 0
        self.temperature_samples = 1
        self.pressure_samples = 1
        self.forced_mode

        # self.forced mode triggered an initial measurement so IIR works properly if enabled.
        # Wait for those values to enter the data registers, but don't read them back.
        sleep @measurement_time

        get_calibration_data
      end

      #
      # Configuration Methods
      #
      def reset
        i2c_write [RESET_REGISTER, RESET_COMMAND]
        sleep UPDATE_TIME
      end

      def iir_coefficient=(coeff)
        raise ArgumentError, "invalid IIR coefficient: #{coeff}" unless IIR_COEFFICIENTS.keys.include? coeff
        i2c_write [IIR_REGISTER, IIR_COEFFICIENTS[coeff]]
        @iir_coefficient = coeff
      end
      attr_reader :iir_coefficient

      def standby_time=(ms)
        raise ArgumentError, "invalid standby time: #{ms}" unless self.class::STANDBY_TIMES.keys.include? ms
        byte = STANDBY_TIMES[ms] << 5
        @standby_time = ms
        i2c_write [STANDBY_TIME_REGISTER, byte]
        sleep UPDATE_TIME
      end
      attr_reader :standby_time

      def temperature_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        @ctrl_meas_register = (@ctrl_meas_register & 0b00011111) | (OVERSAMPLE_FACTORS[factor] << 5)
        @temperature_samples = factor
        calculate_measurement_time
        i2c_write [CTRL_MEAS_REGISTER, @ctrl_meas_register]
        sleep UPDATE_TIME
      end
      attr_reader :temperature_samples

      def pressure_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        @ctrl_meas_register = (@ctrl_meas_register & 0b11100011) | (OVERSAMPLE_FACTORS[factor] << 2)
        @pressure_samples = factor
        calculate_measurement_time
        i2c_write [CTRL_MEAS_REGISTER, @ctrl_meas_register]
        sleep UPDATE_TIME
      end
      attr_reader :pressure_samples

      def calculate_measurement_time
        @measurement_time = (@temperature_samples.to_i * TEMPERATURE_SAMPLE_TIME) +
                           (@pressure_samples.to_i * PRESSURE_SAMPLE_TIME)
        # Add 5ms for safety and convert to seconds.
        @measurement_time = (@measurement_time + 5) * 0.001
      end

      def forced_mode
        @ctrl_meas_register = (@ctrl_meas_register & 0b11111100) | FORCED_MODE
        i2c_write [CTRL_MEAS_REGISTER, @ctrl_meas_register]
        @forced_mode = true
        sleep UPDATE_TIME
      end

      def continuous_mode
        @ctrl_meas_register = (@ctrl_meas_register & 0b11111100) | NORMAL_MODE
        i2c_write [CTRL_MEAS_REGISTER, @ctrl_meas_register]
        @forced_mode = false
        sleep UPDATE_TIME
      end

      def chip_id
        return @chip_id if @chip_id
        bytes = i2c_read_raw(1, register: CHIP_ID_REGISTER)
        @chip_id = bytes[0] if bytes
        @chip_id
      end

      #
      # Reading & Processing
      #
      def _read
        if @forced_mode
          # Write CTRL_MEAS register to trigger reading, then wait for measurement.
          i2c_write [CTRL_MEAS_REGISTER, @ctrl_meas_register]
          sleep @measurement_time
        end

        # Read the data bytes.
        i2c_read(DATA_LENGTH, register: DATA_REGISTER)
      end

      def pre_callback_filter(bytes)
        return nil unless bytes.length == DATA_LENGTH

        # Temperature and pressure are 24-bits long each, and need 2^23 subtracted.
        dt = ((bytes[3] << 16) + (bytes[4] << 8) + bytes[5]) - (0b1 << 23)
        dp = ((bytes[0] << 16) + (bytes[1] << 8) + bytes[2]) - (0b1 << 23)

        # Compensated temperature calculated in 1/256 of a degree Celsius.
        tr =  @calibration[:a0] +
              @calibration[:a1] * dt +
              @calibration[:a2] * (dt ** 2)
        @reading[:temperature] = tr / 256.0

        # Compensated pressure calculated in Pascals.
        @reading[:pressure] = @calibration[:b00] +
                              @calibration[:bt1] * tr +
                              @calibration[:bp1] * dp +
                              @calibration[:b11] * (tr * dp)  +
                              @calibration[:bt2] * (tr ** 2) +
                              @calibration[:bp2] * (dp ** 2) +
                              @calibration[:b12] * (dp * (tr ** 2)) +
                              @calibration[:b21] * ((dp ** 2) * tr) +
                              @calibration[:bp3] * (dp ** 3)

        # Return reading for callbacks.
        @reading
      end

      def update_state(hash)
        @state[:temperature] = hash[:temperature]
        @state[:pressure]    = hash[:pressure]
        @state
      end

      def get_config_registers
        bytes = i2c_read_raw(CONFIG_LENGTH, register: IIR_REGISTER)
        if bytes
          @registers = { f1: bytes[0], f2: bytes[1], f3: bytes[2], f4: bytes[3], f5: bytes[4] }
        end
      end
      attr_reader :registers

      #
      # Calibration
      #
      attr_reader :calibration_data_loaded

      CONVERSION_FACTORS = {
        a1:  { A: -6.3e-03,   S: 4.3e-04 },
        a2:  { A: -1.9e-11,   S: 1.2e-10 },
        bt1: { A:  1.0e-01,   S: 9.1e-02 },
        bt2: { A:  1.2e-08,   S: 1.2e-06 },
        bp1: { A:  3.3e-02,   S: 1.9e-02 },
        b11: { A:  2.1e-07,   S: 1.4e-07 },
        bp2: { A: -6.3e-10,   S: 3.5e-10 },
        b12: { A:  2.9e-13,   S: 7.6e-13 },
        b21: { A:  2.1e-15,   S: 1.2e-14 },
        bp3: { A:  1.3e-16,   S: 7.9e-17 },
        a0:  16.0,
        b00: 16.0,
      }

      def get_calibration_data
        bytes = i2c_read_raw(CALIBRATION_LENGTH, register: CALIBRATION_REGISTER)

        if bytes
          # These 2 values are 20-bit instead of 16-bit, so can't combine them with #pack.
          a0_unsigned  = (bytes[18] << 12) + (bytes[19] << 4) + (bytes[24] & 0b00001111)
          b00_unsigned = (bytes[0] << 12) + (bytes[1] << 4) + ((bytes[24] & 0b11110000) >> 4)

          # Cast the raw bytes as big-endian signed.
          @calibration_raw = {
            # Shift these to 32-bit before converting to signed, then reverse the shift after.
            a0: [(a0_unsigned << 12)].pack('L>').unpack('l>')[0] >> 12,
            b00: [(b00_unsigned << 12)].pack('L>').unpack('l>')[0] >> 12,

            a1: bytes[20..21].pack('C*').unpack('s>')[0],
            a2: bytes[22..23].pack('C*').unpack('s>')[0],

            b11: bytes[8..9].pack('C*').unpack('s>')[0],
            b12: bytes[12..13].pack('C*').unpack('s>')[0],
            b21: bytes[14..15].pack('C*').unpack('s>')[0],

            bp1: bytes[6..7].pack('C*').unpack('s>')[0],
            bp2: bytes[10..11].pack('C*').unpack('s>')[0],
            bp3: bytes[16..17].pack('C*').unpack('s>')[0],

            bt1: bytes[2..3].pack('C*').unpack('s>')[0],
            bt2: bytes[4..5].pack('C*').unpack('s>')[0],
          }

          # Use conversion formulae to calculate compensation coefficients, all as floats.
          @calibration = {}
          @calibration_raw.keys.each do |key|
            if CONVERSION_FACTORS[key].class == Float
              @calibration[key] = @calibration_raw[key] / CONVERSION_FACTORS[key]
            else
              @calibration[key] = CONVERSION_FACTORS[key][:A] + (CONVERSION_FACTORS[key][:S] * @calibration_raw[key] / 32767.0)
            end
          end

          @calibration_data_loaded = true
        end
      end
    end
  end
end
