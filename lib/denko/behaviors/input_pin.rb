module Denko
  module Behaviors
    module InputPin
      include SinglePin
      
      def _stop_listener
        board.stop_listener(pin)
      end

      def debounce_time=(value)
        board.set_pin_debounce(pin, value)
      end

    protected
    
      def initialize_pins(options={})
        super(options)
        
        # Assume input direction, and look for pull mode in options.
        initial_mode = :input
        initial_mode = :input_pullup   if options[:pullup]
        initial_mode = :input_pulldown if options[:pulldown]

        # If user was explicit about mode, just use that.
        initial_mode = options[:mode]  if options[:mode]
        
        self.mode = initial_mode
      end
    end
  end
end
