module Denko
  module SPI
    class OutputRegister < SPI::BaseRegister
      include Behaviors::OutputRegister
      include Behaviors::Lifecycle

      after_initialize do
        write
      end

      # Called by Beaviors::OutputRegister to write @state.
      def _write(bytes)
        spi_write(@state)
      end
    end
  end
end
