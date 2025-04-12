module Denko
  module DigitalIO
    class Output
      include Behaviors::OutputPin
      include Behaviors::Callbacks
      include Behaviors::Threaded
      include Behaviors::Lifecycle

      interrupt_with :digital_write

      after_initialize do
        @board.digital_read(pin) unless @board.platform == :linux_milkv_duo
      end

      def pre_callback_filter(board_state)
        board_state.to_i
      end

      def digital_write(value)
        @board.digital_write(@pin, value)
        self.state = value
      end

      alias :write :digital_write

      def low
        digital_write(board.low)
      end

      def high
        digital_write(board.high)
      end

      def toggle
        state == board.low ? high : low
      end

      alias :off :low
      alias :on  :high

      def high?; state == board.high end
      def low?;  state == board.low  end

      alias :on?  :high?
      alias :off? :low?
    end
  end
end
