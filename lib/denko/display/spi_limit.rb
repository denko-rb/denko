module Denko
  module Display
    module SPILimit
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
