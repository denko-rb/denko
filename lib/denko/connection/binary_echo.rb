module Denko
  module Connection
    class BinaryEcho
      include Behaviors::SinglePin
      include Behaviors::Reader

      def test_range(min:0, max:255)
        bytes = (min..max).to_a
        board.binary_echo(pin, bytes)
      end

      def test_array(arr)
        board.binary_echo(pin, arr)
      end
    end
  end
end
