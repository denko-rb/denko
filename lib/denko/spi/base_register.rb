module Denko
  module SPI
    class BaseRegister
      include SPI::Peripheral::SinglePin
      #
      # Registers can be a BoardProxy for components needing digital pins.
      # Give the Register as board: and pin: is the Register's parallel pin number.
      #
      include Behaviors::BoardProxy

      attr_reader :bytes

      def before_initialize(options={})
        super(options)
        #
        # How many bytes (pins / 8)  for use as BoardProxy. Default to 1 (8 pins).
        # Can be ignored if reading / writing the register directly.
        #
        @bytes = options[:bytes] || 1
      end

      def after_initialize(options={})
        super(options)
        # Select pin is active-low.
        self.high
      end

      #
      # When used as BoardProxy, store the state of each register
      # pin as a 0 or 1 in an array that is (@bytes * 8) long.
      #
      def state
        state_mutex.synchronize { @state ||= Array.new(@bytes*8) { 0 } }
      end
    end
  end
end
