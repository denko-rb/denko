module Denko
  module I2C
    class BitBang
      include Behaviors::MultiPin
      include Behaviors::Lifecycle
      include BusCommon

      def initialize_pins
        proxy_pin :scl, DigitalIO::CBitBang
        proxy_pin :sda, DigitalIO::CBitBang
      end

      after_initialize do
        # Data received for the SDA pin is really for the bus.
        sda.add_callback(:bus_forwarder) { |data| self.update(data) }
        board.i2c_bb_setup(pins[:scl], pins[:sda])
      end

      def _search
        board.i2c_bb_search(pins[:scl], pins[:sda])
      end

      def write(address, bytes, frequency=nil, repeated_start=false)
        board.i2c_bb_write(pins[:scl], pins[:sda], address, bytes, repeated_start)
      end

      def _read(address, register, num_bytes, frequency=nil, repeated_start=false)
        board.i2c_bb_read(pins[:scl], pins[:sda], address, register, num_bytes, repeated_start)
      end
    end
  end
end
