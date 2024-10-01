module Denko
  module SPI
    class OutputRegister < BaseRegister
      include Behaviors::Lifecycle

      after_initialize do
        state
        write
      end

      #
      # Overrides Peripheral#write to always write state.
      # Convert bit state to array of 0-255 integers (bytes) first.
      #
      def write
        bytes = []
        state_mutex.synchronize do
          return if @previous_state == @state
          @state.each_slice(8) do |slice|
            # Convert nils in the slice to zero.
            zeroed = slice.map { |bit| bit.to_i }

            # Each slice is 8 bits of a byte, with the lowest on the left.
            # Reverse to reading order (lowest right) then join into string, and convert to integer.
            byte = zeroed.reverse.join.to_i(2)

            # Pack bytes in reverse order.
            bytes.unshift byte
          end
          @previous_state = @state.dup
        end
        spi_write(bytes)
      end

      #
      # BoardProxy interface
      #
      def digital_write(pin, value)
        bit_set(pin, value)
        write
      end

      def bit_set(pin, value)
        state_mutex.synchronize { @state[pin] = value }
      end

      def digital_read(pin)
        state[pin]
      end
    end
  end
end
