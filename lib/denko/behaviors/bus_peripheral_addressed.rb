module Denko
  module Behaviors
    module BusPeripheralAddressed
      include Denko::Behaviors::BusPeripheral

      def before_initialize(options={})
        # Aallow @address override in options, even if peripheral sets default.
        @address = options[:address] if options[:address]

        raise ArgumentError, "missing address for #{self}. Try Bus#search first" unless @address
        super(options)
      end
    end
  end
end
