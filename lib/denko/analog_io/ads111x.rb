module Denko
  module AnalogIO
    module ADS111X
      #
      # Functionality shared among the ADS111X class of ADC converters.
      #
      include Behaviors::Reader
      attr_accessor :config_register, :active_pin, :active_gain

      PGA_SETTINGS = [  # Bitmask   Full scale voltage
        0.0001875,      # 0b000     6.144 V
        0.000125,       # 0b001     4.095 V
        0.0000625,      # 0b010     2.048 V (default)
        0.00003125,     # 0b011     1.024 V
        0.000015625,    # 0b100     0.512 V
        0.0000078125,   # 0b101     0.256 V
        0.0000078125,   # 0b110     0.256 V
        0.0000078125,   # 0b111     0.256 V
      ]
      PGA_RANGE = (0..7).to_a

      # Sample rate bitmask maps to sample time in seconds.
      SAMPLE_TIMES = [  # Bitmask
        0.125,          # 0b000
        0.0625,         # 0b001
        0.03125,        # 0b010
        0.015625,       # 0b011
        0.0078125,      # 0b100 (default)
        0.004,          # 0b101
        0.002105263,    # 0b110
        0.00116279,     # 0b111
      ]
      SAMPLE_RATE_RANGE = (0..7).to_a

      # Wait times need to be slightly longer than the actual sample times.
      WAIT_TIMES = SAMPLE_TIMES.map { |time| time + 0.0005 }

      # Mux bits map to array of form [positive input, negative input].
      MUX_SETTINGS = {
        0b000 => [0, 1],
        0b001 => [0, 3],
        0b010 => [1, 3],
        0b011 => [2, 3],
        0b100 => [0, nil],
        0b101 => [1, nil],
        0b110 => [2, nil],
        0b111 => [3, nil],
      }

      #
      # BoardProxy behavior so AnalogIO classes can use this as a Board.
      #
      include Behaviors::BoardProxy

      # Mimic Board#update, but inside a callback, wrapped by #update.
      def enable_proxy
        self.add_callback(:board_proxy) do |value|
          components.each do |component|
            if active_pin == component.pin
              component.volts_per_bit = PGA_SETTINGS[active_gain]
              component.update(value)
            end
          end
        end
      end

      def pre_callback_filter(bytes)
        # Pack the 2 bytes into a string, then unpack as big-endian int16.
        value = bytes.pack("C*").unpack("s>")[0]
      end

      def analog_read(pin, negative_pin=nil, gain=nil, sample_rate=nil)
        # Wrap in mutex so calls and callbacks are atomic.
        mutex.lock

        # Default gain and sample rate.
        gain        ||= 0b010
        sample_rate ||= 0b100

        # Set these for callbacks.
        self.active_pin   = pin
        self.active_gain  = gain

        # Set gain in upper config register.
        raise ArgumentError "wrong gain: #{gain.inspect} given for ADS111X" unless PGA_RANGE.include?(gain)
        config_register[0] = self.class::BASE_MSB | (gain << 1)

        # Set mux bits in upper config register.
        mux_bits = pins_to_mux_bits(pin, negative_pin)
        config_register[0] = config_register[0] | (mux_bits << 4)

        # Set sample rate in lower config_register.
        raise ArgumentError "wrong sample_rate: #{sample_rate.inspect} given for ADS111X" unless SAMPLE_RATE_RANGE.include?(sample_rate)
        config_register[1] = self.class::BASE_LSB | (sample_rate << 5)

        result = read(config_register)
        mutex.unlock

        result
      end

      def pins_to_mux_bits(pin, negative_pin)
        # Pin 1 is negative input. Only pin 0 can be read.
        if negative_pin == 1
          raise ArgumentError, "given pin: #{pin.inspect} cannot be used when pin 1 is negative input, only 0" unless pin == 0
          return 0b000
        end

        # Pin 3 is negative input. Pins 0..2 can be read.
        if negative_pin == 3
          raise ArgumentError, "given pin: #{pin.inspect} cannot be used when pin 3 is negative input, only 0..2" unless [0,1,2].include? pin
          return 0b001 + pin
        end

        # No negative input. Any pin from 0 to 3 can be read.
        unless negative_pin
          raise ArgumentError, "given pin: #{pin.inspect} is out of range 0..3" unless [0,1,2,3].include? pin
          return (0b100 + pin)
        end

        raise ArgumentError, "only pins 1 and 3 can be used as negative input"
      end

      def analog_listen(pin, divider=nil)
        raise StandardError, "ADS111X does not implement #listen for subcomponents. Use #read or #poll instead"
      end

      def stop_listener(pin)
      end

      def mutex
        # mruby doesn't have Thread or Mutex, so only stub there.
        @mutex ||= Denko.mruby? ? Denko::MutexStub.new : Mutex.new
      end

      def config_register
        @config_register ||= self.class::CONFIG_STARTUP.dup
      end
    end
  end
end
