module Denko
  module UART
    module Common
      def initialize_buffer
        flush

        self.add_callback(:buffer) do |data|
          @buffer = "#{@buffer}#{data}"
        end
      end

      def gets
        line = nil

        newline = @buffer.index("\n")
        if newline
          line = @buffer[0..newline-1]
          @buffer = @buffer[newline+1..-1]
        end

        line
      end

      def flush
        @buffer = String.new
      end
    end
  end
end
