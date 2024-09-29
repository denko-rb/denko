module Denko
  module SPI
    module BusCommon
      include Behaviors::BusController
      include Behaviors::Reader
      extend Forwardable

      # Add peripheral to self and the board. It gets callbacks directly from the board.
      def add_component(component)
        # Ignore components with no select pin. Mostly for APA102.
        return unless component.pin

        pins = components.map { |c| c.pin }
        if pins.include? component.pin
          raise ArgumentError, "duplicate select pin for #{component}"
        end

        components << component
        board.add_component(component)
      end

      # Remove peripheral from self and the board.
      def remove_component(component)
        components.delete(component)
        board.remove_component(component)
      end

      # Forward pin control methods to the board, for select pin setup.
      def_delegator :board, :convert_pin
      def_delegator :board, :set_pin_mode

      # If a component calls #stop, that's just a call to Board#spi_stop giving its select pin.
      def_delegator :board, :spi_stop, :stop
    end
  end
end
