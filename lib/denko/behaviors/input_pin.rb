module Denko
  module Behaviors
    module InputPin
      include SinglePin

      INPUT_MODES = [:input, :input_pulldown, :input_pullup]
      
      def _stop_listener
        board.stop_listener(pin)
      end

      def debounce_time=(value)
        board.set_pin_debounce(pin, value)
      end

    protected
    
      def initialize_pins(options={})
        super(options)
        
        # Allow pull direction to be set with :mode, else default to :input.
        if options[:mode]
          initial_mode = options[:mode]
          unless INPUT_MODES.include?(initial_mode)
            raise "invalid input mode: #{initial_mode} given. Should be one of #{INPUT_MODES.inspect}"
          end
        else
          initial_mode = :input
        end

        self.mode = initial_mode
      end
    end
  end
end
