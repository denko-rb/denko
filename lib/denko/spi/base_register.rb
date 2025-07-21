module Denko
  module SPI
    class BaseRegister
      include SPI::Peripheral
      include Behaviors::Lifecycle
      #
      # Registers can be a BoardProxy for components needing digital pins.
      # Give the Register as board: and pin: is the Register's parallel pin number.
      #
      include Behaviors::BoardProxy

      def platform
        :spi_register
      end

      # Default to 1 byte (8 pins), when used as BoardProxy.
      def bytes
        @bytes = params[:bytes] || 1
      end
      attr_writer :bytes

      # Select pin is active-low. Disable.
      after_initialize do
        self.high
      end

      # State for Board proxy as a byte array.
      def state
        @state ||= Array.new(bytes*8) { 0 }
      end
    end
  end
end
