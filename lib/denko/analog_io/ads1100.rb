module Denko
  module AnalogIO
    class ADS1100
      include I2C::Peripheral
      include Behaviors::Poller
      include InputHelper

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
        65_535,         # 0b00      16    8
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

      def before_initialize(options={})
        @i2c_address   = 0x48
        @i2c_frequency = 400_000
        super(options)
      end

      def after_initialize(options={})
        super(options)

        # Unlike some ADS parts, full-scale voltage depends on supply (Vdd). User must specify.
        @full_scale_voltage = options[:full_scale_voltage]
        raise ArgumentError "full-scale voltage not given for ADS1100" unless @full_scale_voltage.is_a?(Numeric)

        # Initialize the config register with our defaults (single conversion).
        @config_register = CONFIG_STARTUP.dup

        # Set gain and sample rate if given.
        self.gain         = options[:gain]        || 1
        self.sample_rate  = options[:sample_rate] || 8

        # Write initial config.
        i2c_write(@config_register)
        sleep WAIT_TIMES[@sample_rate]
      end

      def _read
        # Set bit 7 of the config register and write it to start conversion.
        i2c_write(@config_register | (1<<7))
        
        # Sleep the right amount of time for conversion, based on sample rate bits.
        sleep WAIT_TIMES[@sample_rate]

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

      def gain=(gain)
        raise ArgumentError "wrong gain: #{gain.inspect} given for ADS1100" unless GAINS.include?(gain)
        @config_register = (@config_register & GAIN_CLEAR) | GAINS.index(gain)
        @gain = GAINS.index(gain)
      end

      def sample_rate=(rate)
        raise Argument Error "wrong sample_rate: #{sample_rate.inspect} given for ADS1100" unless SAMPLE_RATES.include?(rate)
        @config_register = (@config_register & SAMPLE_RATE_CLEAR) | (SAMPLE_RATES.index(rate) << 2)
        @sample_rate = SAMPLE_RATES.index(rate)
      end

      def gain
        GAINS[@gain]
      end

      def sample_rate
        SAMPLE_RATES[@sample_rate]
      end

      def volts_per_bit
        @full_scale_voltage / (GAINS[@gain] * BIT_RANGES[@sample_rate]).to_f
      end
    end
  end
end
