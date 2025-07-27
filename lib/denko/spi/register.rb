module Denko
  module SPI
    module Register
      include SPI::Peripheral
      include Behaviors::Register
      include Behaviors::Lifecycle

      def platform
        :spi_register
      end

      # Select pin is active-low. Disable.
      after_initialize do
        self.high
      end
    end
  end
end
