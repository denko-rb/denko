module Denko
  module Sensor
    class TSL2561
      include I2C::Peripheral
      include Behaviors::Poller
      include Behaviors::Lifecycle

      I2C_ADDRESS = 0x39

      # These combine the appropriate write command (upper 4 bits), with the register address (lower 4 bits).
      TIMING_REGISTER_ADDR  = 0x81
      DATA_REGISTER_ADDR    = 0x9C
      CONTROL_REGISTER_ADDR = 0x80

      CONTROL_ON  = 0x03
      CONTROL_OFF = 0x00

      # Keys = Bits 1:0 of @timing_register. Values = integration time in ms.
      INTEGRATION_TIMES = {
        0b00 => 13.7,
        0b01 => 101.0,
        0b10 => 402.0
      }
      INTEGRATION_MASK = 0b1111_1100

      # Keys = Bit 4 of @timing_register. Values = 1x or 16x.
      GAINS = {
        0b0 => 1,
        0b1 => 16
      }
      GAIN_MASK = 0b1110_1111

      after_initialize do
        on
        # Defaults
        self.gain = 16
        self.integration_time = 402
        self.package_type = :tn
      end

      # Set to :cs to use alternate constants for calculations.
      attr_accessor :package_type

      def on
        i2c_write [CONTROL_REGISTER_ADDR, CONTROL_ON]
      end

      def off
        i2c_write [CONTROL_REGISTER_ADDR, CONTROL_OFF]
      end

      def gain=(value)
        raise ArgumentError, "invalid gain: #{value}. Must be one of: #{GAINS.values.inspect}" unless GAINS.values.include?(value)
        self.timing_register = (timing_register & GAIN_MASK) | (GAINS.key(value) << 4)
        write_timing_register
        @gain = value
        @gain_scaler = GAINS.values.last / @gain.to_f
      end

      def integration_time=(value)
        float = value.to_f
        raise ArgumentError, "invalid integration_time: #{value}. Must be one of: #{INTEGRATION_TIMES.values.inspect}" unless INTEGRATION_TIMES.values.include?(float)
        self.timing_register = (timing_register & INTEGRATION_MASK) | INTEGRATION_TIMES.key(float)
        write_timing_register
        @integration_time = float
        @integration_scaler = INTEGRATION_TIMES.values.last / @integration_time
      end

      attr_reader :gain, :gain_scaler, :integration_time, :integration_scaler

      def write_timing_register
        i2c_write [TIMING_REGISTER_ADDR, timing_register]
      end

      def timing_register
        @timing_register ||= 0x00
      end

      attr_writer :timing_register

      def _read
        i2c_read(4, register: DATA_REGISTER_ADDR)
      end

      def pre_callback_filter(bytes)
        # Calculations expect 16x gain and 402ms integration time.
        # Normalize readings if different settings are being used.
        ch0 = ((bytes[1] << 8) | bytes[0]) * gain_scaler * integration_scaler
        ch1 = ((bytes[3] << 8) | bytes[2]) * gain_scaler * integration_scaler

        ratio = ch1 / ch0
        lux = nil

        # Calculations from datasheet.
        if @package_type == :cs
          if (ratio <= 0.52)
            lux = (0.0315 * ch0) - (0.0593 * ch0 * (ratio ** 1.4))
          elsif (ratio <= 0.65)
            lux = (0.0229 * ch0) - (0.0291 * ch1)
          elsif (ratio <= 0.80)
            lux = (0.0157 * ch0) - (0.0180 * ch1)
          elsif (ratio <= 1.30)
            lux = (0.00338 * ch0) - (0.00260 * ch1)
          else
            lux = 0
          end
        else
          if (ratio <= 0.50)
            lux = (0.0304 * ch0) - (0.062 * ch0 * (ratio ** 1.4))
          elsif (ratio <= 0.61)
            lux = (0.0224 * ch0) - (0.031 * ch1)
          elsif (ratio <= 0.80)
            lux = (0.0128 * ch0) - (0.0153 * ch1)
          elsif (ratio <= 1.30)
            lux = (0.00146 * ch0) - (0.00112 * ch1)
          else
            lux = 0
          end
        end

        lux
      end
    end
  end
end
