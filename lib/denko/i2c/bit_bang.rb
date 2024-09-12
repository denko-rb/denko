module Denko
  module I2C
    class BitBang
      include Behaviors::MultiPin
      include Behaviors::BusControllerAddressed
      include Behaviors::Reader

      def initialize_pins(options={})
        proxy_pin :scl, DigitalIO::CBitBang
        proxy_pin :sda, DigitalIO::CBitBang
      end

      attr_reader :found_devices

      def after_initialize(options={})
        super(options)
        @found_devices = []

        # Denko::PiBoard needs this called once to put pins into the proper modes.
        board.i2c_bb_claim(scl.pin, sda.pin) if board.method_defined?(:i2c_bb_claim)

        bubble_callbacks
      end

      def search
        addresses = read_using -> { board.i2c_bb_search(pins[:scl], pins[:sda]) }
        @found_devices = addresses.split(":").map(&:to_i) if addresses
      end

      def write(address, bytes, frequency=nil, repeated_start=false)
        board.i2c_bb_write(pins[:scl], pins[:sda], address, bytes, repeated_start)
      end

      def _read(address, register, num_bytes, frequency=nil, repeated_start=false)
        board.i2c_bb_read(pins[:scl], pins[:sda], address, register, num_bytes, repeated_start)
      end

      def bubble_callbacks
        self.sda.add_callback(:bus_controller) do |str|
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
