module Denko
  module SPI
    class InputRegister
      include Register
      include Behaviors::InputRegister
      include Behaviors::Poller
      include Behaviors::Listener

      def _read
        spi_read(bytes)
      end

      def listen
        spi_listen(bytes)
      end

      def stop
        spi_stop
      end
    end
  end
end
