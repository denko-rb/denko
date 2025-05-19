module Denko
  module SPI
    module BusCommon
      include Behaviors::BusController
      include Behaviors::Reader

      # Add peripheral to self and the board. It gets callbacks directly from the board.
      def add_component(component)
        # Don't check for select pin uniqueness. Board handles that.
        components << component
      end

      # Remove peripheral from self and the board.
      def remove_component(component)
        components.delete(component)
      end

      # Pass through to the real board for converting select/other pins.
      def convert_pin(*args, **kwargs)
        board.convert_pin(*args, **kwargs)
      end

      def set_pin_mode(*args, **kwargs)
        board.set_pin_mode(*args, **kwargs)
      end

      # If a component calls #stop, that's just a call to Board#spi_stop giving its select pin.
      def stop(*args, **kwargs)
        board.spi_stop(*args, **kwargs)
      end
    end
  end
end
