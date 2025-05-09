module Denko
  module SPI
    class InputRegister < BaseRegister
      include Behaviors::Lifecycle

      #
      # Keep track of whether anything is listening or reading a specific pin.
      # This might be separate from whether a component is attached or not.
      #
      def reading_pins
        @reading_pins ||= Array.new(bytes*8) { false }
      end

      def listening_pins
        @listening_pins ||= Array.new(bytes*8) { false }
      end

      after_initialize do
        enable_proxy
      end

      def read
        spi_read(bytes)
      end

      def listen
        spi_listen(bytes)
      end

      def stop
        spi_stop
      end

      #
      # BoardProxy interface
      #
      def digital_read(pin)
        # Remember what pin was read and force callbacks to run next update.
        add_callback(:force_update) { Proc.new{} }
        reading_pins[pin] = true

        # Don't actually call #read if already listening.
        read unless any_listening
      end

      def digital_listen(pin, divider)
        listen unless any_listening
        listening_pins[pin] = true
      end

      def stop_listener(pin)
        listening_pins[pin] = false
        stop unless any_listening
      end

      def any_listening
        listening_pins.each { |p| return true if p }
        false
      end

      #
      # Mimic Board#update, but in a callback fired through #update.
      # This doesn't interfere with using the register directly,
      # and doesn't fire if the board isn't acting as a proxy (no components).
      #
      def enable_proxy
        self.add_callback(:board_proxy) do |bit_array|
          bit_array.each_with_index do |value, pin|
            components.each do |part|
              update_component(part, pin, value) if pin == part.pin
            end
            reading_pins[pin] = false
          end
        end
      end

      #
      # Override Callbacks#update to make sure we handle :force_update
      # within the main mutex lock.
      #
      def update(message)
        # Since overriding update, make sure this is a byte array first.
        byte_array = ensure_byte_array(message)

        bits = byte_array_to_bit_array(byte_array)

        @callback_mutex.lock
        if @callbacks && !@callbacks.empty?
          # Arduino doesn't de-duplicate state. Do it, but honor :force_update callbacks.
          if (bits != state) || @callbacks[:force_update]
            @callbacks.each_value do |array|
              array.each { |callback| callback.call(bits) }
            end
          end

          # Remove both :read and :force update while inside the lock.
          @callbacks.delete(:read)
          @callbacks.delete(:force_update)
        end
        @callback_mutex.unlock

        self.state = bits
      end

      def update_component(part, pin, value)
        # Update if component is listening and value has changed.
        if listening_pins[pin] && (value != state[pin])
          part.update(value)
        # Also update if the component forced a read.
        # Always called inside @callback_mutex, so @callbacks, not callbacks
        elsif reading_pins[pin] && @callbacks[:force_update]
          part.update(value)
        end
      end

      #
      # Convert array of bytes coming from the register into an array of bits
      # to update self state and give to component callbacks.
      #
      def byte_array_to_bit_array(byte_array)
        #
        # For each array element (1 byte):
        # decimal number as string -> integer -> padded string of binary digits
        # -> reverse digits from reading order to array indexing order
        # -> join digits of all bytes into one string
        #
        binary_string = byte_array.map do |byte|
          byte.to_i.to_s(2).rjust(8, "0").reverse
        end.join

        # Split the digits out of the string into individual integers.
        binary_string.split("").map { |bit| bit.to_i }
      end
    end
  end
end
