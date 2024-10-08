module Denko
  module EEPROM
    class BuiltIn
      include Behaviors::Component
      include Behaviors::Reader
      include Behaviors::Lifecycle

      public :state=

      def pin
        254
      end

      after_initialize do
        load
      end

      def state
        state_mutex.synchronize { @state ||= Array.new(board.eeprom_length, nil) }
      end

      def load
        state.each_slice(128).with_index do |slice, index|
          read_using -> { board.eeprom_read(index * 128, slice.length) }
        end
      end

      def save
        state_mutex.synchronize do
          @state.each_slice(128).with_index do |slice, index|
            board.eeprom_write(index * 128, slice)
          end
        end
        load
      end

      #
      # Specific Array-like methods for convenience.
      #
      def length; board.eeprom_length; end
      alias :count :length

      def [](index)
        state_mutex.synchronize { @state.send :[], index }
      end

      def []=(index, value)
        state_mutex.synchronize { @state.send :[]=, index, value }
      end

      def each(&block)
        state_mutex.synchronize { @state.send :each, &block }
      end

      def each_with_index(&block)
        state_mutex.synchronize { @state.send :each_with_index, &block }
      end

      def pre_callback_filter(message)
        address = message.split("-", 2)[0].to_i
        bytes = message.split("-", 2)[1].split(",").map(&:to_i)
        {address: address, data: bytes}
      end

      def update_state(hash)
        state_mutex.synchronize do
          @state[hash[:address], hash[:data].length] = hash[:data]
        end
      end
    end
  end
end
