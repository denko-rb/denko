module Denko
  module Behaviors
    module InputPin
      include Component
      include SinglePin
      include Lifecycle

      INPUT_MODES = [:input, :input_pulldown, :input_pullup, :input_adc]

      before_initialize do
        params[:mode] ||= :input
        unless INPUT_MODES.include?(params[:mode])
          raise "invalid input mode: #{params[:mode]} given. Should be one of #{INPUT_MODES.inspect}"
        end
      end

      def _stop_listener
        board.stop_listener(pin)
      end

      def debounce_time=(value)
        board.set_pin_debounce(pin, value)
      end
    end
  end
end
