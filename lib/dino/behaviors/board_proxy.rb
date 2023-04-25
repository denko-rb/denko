module Dino
  module Behaviors
    module BoardProxy
      include BusController

      def high
        1
      end

      def low
        0
      end

      def convert_pin(pin)
        pin.to_i
      end

      def set_pin_mode(pin, mode, pull=nil); end

      def start_read; end
    end
  end
end