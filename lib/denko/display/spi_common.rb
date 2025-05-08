module Denko
  module Display
    module SPICommon
      include SPI::Peripheral::MultiPin
      include PixelCommon

      #
      # SPI displays use a D/C pin to toggle whether bytes being sent are data or commands.
      # Most also have a RESET pin which is pulsed low to initalize, then held high.
      #
      def initialize_pins(options={})
        super(options)
        proxy_pin :dc,    DigitalIO::Output, board: bus.board
        proxy_pin :reset, DigitalIO::Output, board: bus.board, optional: true
        reset.high if reset
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

      def transfer_limit
        return @transfer_limit if @transfer_limit
        # Calculate remaining space after aux uses 8 bytes for SPI header.
        aux_limit = bus.board.aux_limit - 8
        # Should change this, but Board limits SPI data length to 255 excl. header. Use the lower one.
        @transfer_limit = (aux_limit < 264) ? aux_limit : 255
      end
    end
  end
end
