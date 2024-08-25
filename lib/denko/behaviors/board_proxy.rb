module Denko
  module Behaviors
    module BoardProxy
      include Subcomponents

      def high
        1
      end

      def low
        0
      end

      def convert_pin(pin)
        pin.to_i
      end

      def set_pin_mode(pin, mode); end

      def start_read; end
    end
  end
end
