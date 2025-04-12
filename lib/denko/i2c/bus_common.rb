module Denko
  module I2C
    module BusCommon
      include Behaviors::BusControllerAddressed
      include Behaviors::Reader
      include Behaviors::Lifecycle

      after_initialize do
        bubble_callbacks
      end

      def found_devices
        @found_devices ||= []
      end
      attr_writer :found_devices

      def search
        addresses = read_using -> { _search }
        if addresses.class == String
          @found_devices = addresses.split(":").map(&:to_i).reject{ |e| e==0 }
        elsif addresses.class == Array
          # 0th element being 0 (invalid address) means the array contains search results,
          # instead of bytes read from a peripheral. Remove it.
          @found_devices = addresses - [0]
        end
      end

      def bubble_callbacks
        add_callback(:bus_controller) do |data|
          bytes = nil

          # Array data from PiBoard.
          if data.class == Array
            address = data[0]
            bytes = data[1..-1]

          # String data from microcontroller.
          elsif (data.class == String) && (data.match /\A\d+-/)
            address, bytes = data.split("-", 2)
            address = address.to_i
            bytes = bytes.split(",").map(&:to_i)
            bytes = nil if bytes.empty?
          end

          # Update components.
          components.each { |c| c.update(bytes) if c.address == address } if bytes
        end
      end
    end
  end
end
