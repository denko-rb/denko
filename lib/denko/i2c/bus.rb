module Denko
  module I2C
    class Bus
      include Behaviors::SinglePin
      include Behaviors::BusControllerAddressed
      include Behaviors::Reader

      attr_reader :found_devices

      def after_initialize(options={})
        super(options)
        @found_devices = []
        bubble_callbacks
      end

      def search
        addresses = read_using -> { board.i2c_search }
        @found_devices = addresses.split(":").map(&:to_i) if addresses
      end

      def write(address, bytes, frequency=100000, repeated_start=false)
        board.i2c_write(address, bytes, frequency, repeated_start)
      end

      def _read(address, register, num_bytes, frequency=100000, repeated_start=false)
        board.i2c_read(address, register, num_bytes, frequency, repeated_start)
      end
      
      def bubble_callbacks
        add_callback(:bus_controller) do |str|
          if str && str.match(/\A\d+-/)
            address, data = str.split("-", 2)
            address = address.to_i

            data = data.split(",").map(&:to_i)
            data = nil if data.empty?

            components.each do |component|
              component.update(data) if component.address == address
            end
          end
        end
      end
    end
  end
end
