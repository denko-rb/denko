module Denko
  module AnalogIO
    class Joystick
      include Behaviors::MultiPin
      include Behaviors::Lifecycle

      def initialize_pins(options={})
        proxy_pin(:x, AnalogIO::Input)
        proxy_pin(:y, AnalogIO::Input)
      end

      after_initialize do
        # Midpoint as float
        @mid  = board.adc_high / 2.0

        # Invert settings as +1 or -1 multipliers
        @invert_x = params[:invert_x] ? -1 : 1
        @invert_y = params[:invert_y] ? -1 : 1

        # Deadzones as percentages
        @deadzone = 0
        @maxzone  = @mid
        @deadzone = ((params[:deadzone] * @mid) / 100).round if params[:deadzone]
        @maxzone  = ((params[:maxzone] * @mid) / 100).round if params[:maxzone]

        # Per axis callbacks
        x.on_data { |value| state[:x] = raw_to_percent(value, @invert_x) }
        y.on_data { |value| state[:y] = raw_to_percent(value, @invert_y) }
      end

      def state
        @state ||= { x: nil, y: nil }
      end

      def raw_to_percent(value, invert)
        float = (value - @mid) * invert
        abs   = float.abs
        if abs < @deadzone
          return 0
        elsif abs > @maxzone
          return (float > 0) ? 100 : -100
        else
          return ((float * 100) / @mid).round
        end
      end

      def read
        # Blocking read only for last axis read.
        x._read
        y.read
        state
      end

      def listen(divider=16)
        x.listen(divider)
        y.listen(divider)
      end

      def stop
        x.stop
        y.stop
      end
    end
  end
end
