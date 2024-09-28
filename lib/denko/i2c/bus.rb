module Denko
  module I2C
    class Bus
      include Behaviors::Lifecycle
      include BusCommon

      def i2c_index
        @i2c_index ||= params[:i2c_index] || params[:index] || 0
      end

      def found_devices
        @found_devices ||= []
      end
      attr_writer :found_devices

      def search
        addresses = read_using -> { board.i2c_search(i2c_index) }
        @found_devices = addresses.split(":").map(&:to_i) if addresses
      end

      def write(address, bytes, frequency=100000, repeated_start=false)
        board.i2c_write(i2c_index, address, bytes, frequency, repeated_start)
      end

      def _read(address, register, num_bytes, frequency=100000, repeated_start=false)
        board.i2c_read(i2c_index, address, register, num_bytes, frequency, repeated_start)
      end
    end
  end
end
