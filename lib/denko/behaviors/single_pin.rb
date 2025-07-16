module Denko
  module Behaviors
    module SinglePin
      include Component
      attr_reader :pin, :mode

      def mode=(mode)
        board.set_pin_mode(pin, mode)
        @mode = mode
      end

      def convert_pins
        raise ArgumentError, 'a pin is required for this component' unless params[:pin]
        params[:pin] = board.convert_pin(params[:pin])
      end

      def initialize_pins
        @pin = params[:pin]
        self.mode = params[:mode] if params[:mode]
      end
    end
  end
end
