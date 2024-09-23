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
        @counts_per_revolution = options[:counts_per_revolution] || options[:cpr] || 60
        @reversed = false || options[:reversed] || options[:reverse]

        # Avoid repeated memory allocation.
        @reading   = { count: 0, angle: 0, change: 0}

        # PiBoard will use GPIO alerts, default to 1 microsecond debounce time.
        @debounce_time = options[:debounce_time] || 1
        a.debounce_time = @debounce_time
        b.debounce_time = @debounce_time

        # Board will default to 1ms digital listeners.
        @divider = options[:divider] || 1
        a.listen(@divider)
        b.listen(@divider)

        # Let initial state settle.
        sleep 0.010

        observe_pins
        reset
      end

      def state
        state_mutex.synchronize { @state ||= { count: 0, angle: 0 } }
      end

      attr_reader :reversed, :counts_per_revolution, :divider, :debounce_time

      def reverse
        @reversed = !@reversed
      end

      def degrees_per_count
        @degrees_per_count ||= (360 / @counts_per_revolution.to_f)
      end

      def angle
        state[:angle]
      end

      def count
        state[:count]
      end

      def reset
        self.state = {count: 0, angle: 0}
      end

      private

      def observe_pins
        a.add_callback do |a_state|
          self.update((a_state == b.state) ? 1 : -1)
        end

        b.add_callback do |b_state|
          self.update((b_state == a.state) ? -1 : 1)
        end
      end

      #
      # Take data (+/- 1 step change) and calculate new state.
      # Return a hash with the new :count and :angle. Pass through raw
      # value in :change, so callbacks can use any of these.
      #
      def pre_callback_filter(step)
        step = -step if reversed

        state_mutex.synchronize { @reading[:count] = @state[:count] + step }
        @reading[:change] = step
        @reading[:angle]  = @reading[:count] * degrees_per_count % 360

        @reading
      end

      #
      # After callbacks, set state to the hash from before, except change.
      #
      def update_state(reading)
        state_mutex.synchronize do
          @state[:count] = reading[:count]
          @state[:angle] = reading[:angle]
        end
      end
    end
  end
end
