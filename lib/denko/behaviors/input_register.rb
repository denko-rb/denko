module Denko
  module Behaviors
    module InputRegister
      include Register
      include Lifecycle

      after_initialize do
        @reading_pins   = Array.new(bytes*8) { false }
        @listening_pins = Array.new(bytes*8) { false }

        self.add_callback(:board_proxy) do |byte_array|
          byte_array.each_with_index do |byte, byte_index|
            for bit in 0..7 do
              pin       = (byte_index * 8) + bit
              value     = (byte >> bit) & 0b1

              next unless components[pin]

              if (@reading_pins[pin])
                components[pin].update(value)
                @reading_pins[pin] = false
              elsif (@listening_pins[pin])
                old_value = (@state[byte_index] >> bit) & 0b1
                components[pin].update(value) if value != old_value
              end
            end
          end
        end
      end

      # Including classes should implement #_read and #pre_callback_filter such
      # that #update receives a byte array representing pin states, LSBIT and LSBYTE first.
      def update_state(byte_array)
        byte_array.each_with_index  { |byte, i| @state[i] = byte }
      end

      def digital_read(pin)
        @reading_pins[pin] = true
        read unless @listening_pins.any?
      end

      def digital_listen(pin, divider)
        listen unless @listening_pins.any?
        @listening_pins[pin] = true
      end

      def stop_listener(pin)
        @listening_pins[pin] = false
        stop unless @listening_pins.any?
      end
    end
  end
end
