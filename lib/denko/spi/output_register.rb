module Denko
  module SPI
    class OutputRegister < SPI::BaseRegister
      include Behaviors::OutputRegister
      include Behaviors::Lifecycle

      after_initialize do
        old_state
        write
      end

      def old_state
        @old_state ||= Array.new(bytes) { 0 }
      end

      def write
        @state_mutex.lock
          if @state != @old_state
            spi_write(@state)
            @state.each_with_index { |byte, i| @old_state[i] = byte }
          end
        @state_mutex.unlock
        state
      end
    end
  end
end
