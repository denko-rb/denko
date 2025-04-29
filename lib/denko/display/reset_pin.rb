module Denko
  module Display
    module ResetPin
      #
      # Many SPI displays have a  hardware reset pin, in addition to a reset command.
      # It is usually optional, and can be permanently tied high if not used.
      # This mixin handles that behavior for any display like this.
      #
      def initialize_pins(options={})
        super(options)
        proxy_pin :reset, DigitalIO::Output, board: bus.board, optional: true
        reset.high if reset
      end
    end
  end
end
