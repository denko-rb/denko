module Denko
  module DigitalIO
    class RotaryEncoder
      include Behaviors::MultiPin
      include Behaviors::Callbacks

      def initialize_pins(options={})
        # Allow pins to be given as printed on common parts.
        unless options[:pins][:a]
          options[:pins][:a] = options[:pins][:clk] if options[:pins][:clk]
          options[:pins][:a] = options[:pins][:clock] if options[:pins][:clock]
        end
        unless options[:pins][:b]
          options[:pins][:b] = options[:pins][:dt] if options[:pins][:dt]
          options[:pins][:b] = options[:pins][:data] if options[:pins][:data]
        end
        
        # But always refer to them as a and b internally.
        [:clk, :clock, :dt, :data].each { |key| options[:pins].delete(key) }
        proxy_pin :a, DigitalIO::Input
        proxy_pin :b, DigitalIO::Input
      end

      def after_initialize(options={})
        super(options)
        self.steps_per_revolution = options[:steps_per_revolution] || 30
        @reverse = false

        # Avoid repeated memory allocation.
        self.state = { steps: 0, angle: 0 }
        @reading   = { steps: 0, angle: 0, change: 0}
        
        # DigitalInputs listen with default divider automatically. Override here.
        @divider = options[:divider] || 1
        a.listen(@divider)
        b.listen(@divider)
        
        observe_pins
        reset
      end
      
      attr_reader :reversed

      def reverse
        @reversed = !@reversed
      end

      def steps_per_revolution
        (360 / @degrees_per_step).to_i
      end
      
      def steps_per_revolution=(step_count)
        @degrees_per_step = 360.to_f / step_count
      end
      
      def angle
        state[:angle]
      end

      def steps
        state[:steps]
      end
      
      def reset
        self.state = {steps: 0, angle: 0}
      end
      
      private

      def observe_pins
        #
        # This is a quirk of listeners reading in numerical order.
        # When observing the pins, attach a callback to the higher numbered pin (trailing),
        # then read state of the lower numbered (leading). If not, direction will be reversed.
        #
        if a.pin > b.pin
          trailing = a
          leading = b
        else
          trailing = b
          leading = a
        end
        
        trailing.add_callback do |trailing_state|
          change = (trailing_state == leading.state) ? 1 : -1
          change = -change if trailing == a
          self.update(change)
        end
      end
      
      #
      # Take data (+/- 1 step change) and calculate new state.
      # Return a hash with the new :steps and :angle. Pass through raw
      # value in :change, so callbacks can use any of these.
      #
      def pre_callback_filter(step)
        step = -step if reversed

        @reading[:change] = step
        @state_mutex.synchronize do
          @reading[:steps] = @state[:steps] + step
        end      
        @reading[:angle] = @reading[:steps] * @degrees_per_step % 360
        
        @reading
      end

      #
      # After callbacks, set state to the hash from before, except change.
      #
      def update_state(reading)
        @state_mutex.synchronize do
          @state[:steps]  = reading[:steps]
          @state[:angle]  = reading[:angle]
        end
      end
    end
  end
end
