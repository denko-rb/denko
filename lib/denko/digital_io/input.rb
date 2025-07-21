module Denko
  module DigitalIO
    class Input
      include Behaviors::InputPin
      include Behaviors::Reader
      include Behaviors::Poller
      include Behaviors::Listener
      include Behaviors::Lifecycle

      after_initialize do
        _listen(params[:divider] || 4)
      end

      def _read
        board.digital_read(@pin)
      end

      if Denko.mruby?
        # Optimized to bypass *args and **kwargs. Behaves like CRuby.
        def read(&block)
          board.digital_read(@pin)
          # board calls #update on us here.
          block.call(@read_result) if block_given?
          @read_result
        end

        # Bypasses *args, **kwargs, &block, #update, @read_result and @state.
        def read_raw
          board.digital_read_raw(@pin)
        end
      end

      def _listen(divider=nil)
        @divider = divider || @divider
        board.digital_listen(pin, @divider)
      end

      def on_high(&block)
        add_callback(:high) do |data|
          block.call(data) if data.to_i == board.high
        end
      end

      def on_low(&block)
        add_callback(:low) do |data|
          block.call(data) if data.to_i == board.low
        end
      end

      def pre_callback_filter(value)
        value.to_i
      end

      def high?; @state == board.high end
      def low?;  @state == board.low  end
    end
  end
end
