module Denko
  module SPI
    class BaseRegister
      include Behaviors::Component
      include SPI::Peripheral::SinglePin
      #
      # Registers can be a BoardProxy for components needing digital pins.
      # Give the Register as board: and pin: is the Register's parallel pin number.
      #
      include Behaviors::BoardProxy

      # Default registers to 1 byte, or 8 pins when used as Board Proxy.
      # Can be ignored if reading / writing the register directly.
      def bytes
        @bytes ||= 1
      end
      attr_writer :bytes

      before_initialize do
        self.bytes = params[:bytes] if params[:bytes]
      end

      # Select pin is active-low. Disable.
      after_initialize do
        self.high
      end

      #
      # When used as BoardProxy, store the state of each register
      # pin as a 0 or 1 in an array that is (@bytes * 8) long.
      #
      def state
        state_mutex.synchronize { @state ||= Array.new(bytes*8) { 0 } }
      end
    end
  end
end
