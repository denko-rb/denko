module Denko
  module Behaviors
    module SinglePin
      include Component
      attr_reader :pin, :mode

      def mode=(mode)
        board.set_pin_mode(pin, mode)
        @mode = mode
      end

      def convert_pins(options={})
        raise ArgumentError, 'a pin is required for this component' unless options[:pin]
        options[:pin] = board.convert_pin(options[:pin])
      end

      def initialize_pins(options={})
        @pin = options[:pin]
        self.mode = params[:mode] if params[:mode]
      end
    end
  end
end
