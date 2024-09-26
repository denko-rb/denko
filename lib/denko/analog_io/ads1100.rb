module Denko
  module AnalogIO
    class ADS1100
      include Behaviors::Component
      include I2C::Peripheral
      include Behaviors::Poller
      include InputHelper

      I2C_ADDRESS   = 0x48
      I2C_FREQUENCY = 400_000

      # Convert sample rates in samples-per-seconds to their bit representation.
      SAMPLE_RATES = [  # Bitmask
        128,            # 0b00
        32,             # 0b01
        16,             # 0b10
        8               # 0b11 (default)
      ]

      # Faster sampling rates have lower resolution.
      BIT_RANGES = [    # Bitmask   Bits  SPS
        4_096,          # 0b00      12    128
        16_383,         # 0b01      14    32
        32_767,         # 0b10      15    16
        65_535,         # 0b11      16    8
      ]

      # Wait times need to be slightly longer than the actual sample times.
      WAIT_TIMES = SAMPLE_RATES.map { |rate| (1 / rate.to_f) + 0.0005 }

      GAINS = [  # Bitmask   Full scale voltage
        1,       # 0b00      Vdd
        2,       # 0b01      Vdd / 2
        4,       # 0b10      Vdd / 4
        8,       # 0b11      Vdd / 8
      ]

      # Default config register:
      #   Bit 7   : Start conversion (write 1) | Conversion in progress (read 1)
      #   Bit 6-5 : Reserved, must be 00
      #   Bit 4   : Conversion mode. 0 = continuous (datasheet default). 1 = single (our default).
      #   Bit 3-2 : Sample Rate (see array above)
      #   Bit 1-2 : PGA setting (see array above)
      CONFIG_STARTUP = 0b00011100

      # Masks
      GAIN_CLEAR = 0b11111100
      SAMPLE_RATE_CLEAR = 0b11110011

      after_initialize do
        # Validate user gave full scale voltage.
        raise ArgumentError "full-scale voltage not a Numeric or not given for ADS1100" unless full_scale_voltage.is_a?(Numeric)
        state

        i2c_write(config_register)
        sleep WAIT_TIMES[sample_rate_mask]
      end

      def _read
        # Set bit 7 of the config register and write it to start conversion.
        i2c_write(config_register | (1<<7))

        # Sleep the right amount of time for conversion, based on sample rate bits.
        sleep WAIT_TIMES[sample_rate_mask]

        # Read the result, triggering callbacks.
        i2c_read(2)
      end

      def listen(pin, divider=nil)
        raise StandardError, "ADS1100 does not implement #listen. Use #read or #poll instead"
      end

      def pre_callback_filter(bytes)
        # Readings are 16-bits, signed, big-endian.
        value = bytes.pack("C*").unpack("s>")[0]
        # Let InputHelper module handle smooothing.
        super(value)
      end

      # Default to single conversion.
      def config_register
        @config_register ||= CONFIG_STARTUP
      end

      def sample_rate=(rate)
        raise Argument Error "wrong sample_rate: #{sample_rate.inspect} given for ADS1100" unless SAMPLE_RATES.include?(rate)
        self.sample_rate_mask = SAMPLE_RATES.index(rate)
        config_register = (config_register & SAMPLE_RATE_CLEAR) | (sample_rate_mask << 2)
        @sample_rate = rate
      end

      def sample_rate_mask
        @sample_rate_mask ||= SAMPLE_RATES.index(sample_rate)
      end

      def sample_rate
        @sample_rate ||= 8
      end

      attr_writer :sample_rate_mask

      def gain=(gain)
        raise ArgumentError "wrong gain: #{gain.inspect} given for ADS1100" unless GAINS.include?(gain)
        config_register = (config_register & GAIN_CLEAR) | GAINS.index(gain)
        @gain = GAINS.index(gain)
      end

      def gain
        # Default gain is 1.
        self.gain = 1 unless @gain
        GAINS[@gain]
      end

      # Unlike some ADS parts, full-scale voltage depends on supply (Vdd). User must specify.
      def full_scale_voltage
        @full_scale_voltage ||= params[:full_scale_voltage]
      end

      def volts_per_bit
        full_scale_voltage / (GAINS[gain] * BIT_RANGES[sample_rate_mask]).to_f
      end
    end
  end
end
