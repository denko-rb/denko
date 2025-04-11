module Denko
  module UART
    module Common
      def initialize_buffer
        @buffer       = ""
        @buffer_mutex = Denko.gil? ? Denko::MutexStub.new : Mutex.new
        self.add_callback(:buffer) do |data|
          @buffer_mutex.lock
          @buffer = "#{@buffer}#{data}"
          @buffer_mutex.unlock
        end
      end

      def gets
        line = nil
        @buffer_mutex.lock
        newline = @buffer.index("\n")
        if newline
          line = @buffer[0..newline-1]
          @buffer = @buffer[newline+1..-1]
        end
        @buffer_mutex.unlock
        line
      end

      def flush
        @buffer_mutex.lock
        @buffer = ""
        @buffer_mutex.unlock
      end
    end
  end
end
