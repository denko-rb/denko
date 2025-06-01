module Denko
  module Display
    module SPICommon
      include SPI::Peripheral
      include PixelCommon

      #
      # SPI displays use a D/C pin to toggle whether bytes being sent are data or commands.
      # Most also have a RESET pin which is pulsed low to initalize, then held high.
      #
      def initialize_pins(options={})
        super(options)
        proxy_pin :dc,    DigitalIO::Output
        proxy_pin :reset, DigitalIO::Output, optional: true
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
        @transfer_limit ||= bus.board.spi_limit
      end
    end
  end
end
