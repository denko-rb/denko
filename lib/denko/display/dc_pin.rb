module Denko
  module Display
    module DCPin
      #
      # Many SPI displays have use a D/C pin in addition to their usual SPI pins.
      # This mixin handles that behavior for any display like this.
      #
      def initialize_pins(options={})
        super(options)
        proxy_pin :dc, DigitalIO::Output, board: bus.board
      end

      # Commands are SPI bytes written while DC pin is low.
      def command(bytes)
        dc.low
        spi_write(bytes)
      end

      # Display data are SPI SPI bytes written while DC pin is high.
      def data(bytes)
        dc.high
        spi_write(bytes)
      end
    end
  end
end
