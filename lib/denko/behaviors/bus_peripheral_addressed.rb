module Denko
  module Behaviors
    module BusPeripheralAddressed
      include Component
      include BusPeripheral

      def address
        @address ||= params[:address]
      end

      # Validate address presence after initialization.
      after_initialize do
        raise ArgumentError, "no address set for for #{self}. Try Bus#search first" unless address
      end
    end
  end
end
