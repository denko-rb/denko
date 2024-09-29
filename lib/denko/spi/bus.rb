module Denko
  module SPI
    class Bus
      include BusCommon

      # Board expects all components to have #pin.
      attr_reader :pin

      def spi_index
        @spi_index ||= params[:spi_index] || params[:index] || 0
      end

      # Prepend spi_index to these and forward to the board.
      def transfer(*args, **kwargs)
        args.unshift(spi_index)
        board.spi_transfer(*args, **kwargs)
      end

      def listen(*args, **kwargs)
        args.unshift(spi_index)
        board.spi_listen(*args, **kwargs)
      end

      # This is for WS2812 strips on PiBoard.
      def show_ws2812(*args)
        board.show_ws2812(*args, spi_index: spi_index)
      end
    end
  end
end
