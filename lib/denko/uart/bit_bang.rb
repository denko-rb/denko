module Denko
  module UART
    class UARTRxPin
      include Behaviors::InputPin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle
    end

    class BitBang
      include Behaviors::MultiPin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle

      attr_reader :baud

      def initialize_pins(options={})
        require_pin(:tx)
        proxy_pin(:rx, UARTRxPin)
      end

      after_initialize do
        hook_rx_callback
        initialize_buffer
        start(params[:baud] || 9600)
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
        board.uart_bb_start(pins[:tx], pins[:rx], @baud)
      end

      def stop()
        board.uart_bb_stop
      end

      def write(data)
        board.uart_bb_write(data)
      end

      def hook_rx_callback
        rx.add_callback {|data| self.update(data)}
      end
    end
  end
end
