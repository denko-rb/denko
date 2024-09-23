module Denko
  module DigitalIO
    class RotaryEncoder
      include Behaviors::Component
      include Behaviors::MultiPin
      include Behaviors::Callbacks

      def initialize_pins(params={})
        # Allow pins to be given as printed on common parts.
        unless params[:pins][:a]
          params[:pins][:a] = params[:pins][:clk] if params[:pins][:clk]
          params[:pins][:a] = params[:pins][:clock] if params[:pins][:clock]
        end
        unless params[:pins][:b]
          params[:pins][:b] = params[:pins][:dt] if params[:pins][:dt]
          params[:pins][:b] = params[:pins][:data] if params[:pins][:data]
        end

        # But always refer to them as a and b internally.
        [:clk, :clock, :dt, :data].each { |key| params[:pins].delete(key) }
        proxy_pin :a, DigitalIO::Input
        proxy_pin :b, DigitalIO::Input
      end

      after_initialize do
        @counts_per_revolution = params[:counts_per_revolution] || params[:cpr] || 60
        @reversed = false || params[:reversed] || params[:reverse]

        # PiBoard will use GPIO alerts, default to 1 microsecond debounce time.
        @debounce_time = params[:debounce_time] || 1
        a.debounce_time = @debounce_time
        b.debounce_time = @debounce_time

        # Board will default to 1ms digital listeners.
        @divider = params[:divider] || 1
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

      def reading
        @reading ||= { count: 0, angle: 0, change: 0 }
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

        state_mutex.synchronize { reading[:count] = @state[:count] + step }
        reading[:change] = step
        reading[:angle]  = reading[:count] * degrees_per_count % 360

        reading
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
