module Denko
  module UART
    class Hardware
      include Behaviors::Component
      include Behaviors::SinglePin
      include Behaviors::Callbacks

      attr_reader :index, :baud

      before_initialize do
        if params[:index] && (params[:index] > 0) && (params[:index] < 4)
          @index = params[:index]
        else
          raise ArgumentError, "UART index (#{params[:index]}) not given or out of range (1..3)"
        end

        # Set pin to a "virtual pin" in 251 - 253 that will match the board.
        params[:pin] = 250 + params[:index]
      end

      after_initialize do
        initialize_buffer
        start(params[:baud] ||= 9600)
      end

      def initialize_buffer
        @buffer       = ""
        @buffer_mutex = Mutex.new
        self.add_callback(:buffer) do |data|
          @buffer_mutex.synchronize do
            @buffer = "#{@buffer}#{data}"
          end
        end
      end

      def gets
        @buffer_mutex.synchronize do
          newline = @buffer.index("\n")
          return nil unless newline
          line = @buffer[0..newline-1]
          @buffer = @buffer[newline+1..-1]
          return line
        end
      end

      def flush
        @buffer_mutex.synchronize do
          @buffer = ""
        end
      end

      def start(baud)
        @baud = baud
        board.uart_start(index, baud, true)
      end

      def stop()
        board.uart_stop(index)
      end

      def write(data)
        board.uart_write(index, data)
      end
    end
  end
end
