module Denko
  module Motor
    class Servo
      FREQUENCY = 50
      PERIOD_NS = 20_000_000

      include Behaviors::SinglePin
      include Behaviors::Lifecycle

      before_initialize do
        params[:mode] = :output_pwm
      end

      after_initialize do
        attach
      end

      def min
        @min ||= params[:min] || 500
      end

      def max
        @max ||= params[:max] || 2500
      end

      attr_writer :min, :max

      def attach
        if board.platform == :arduino
          board.servo_toggle(pin, :on, min: min, max: max)
        else
          board.set_pin_mode(pin, :output_pwm, {frequency: FREQUENCY, period: PERIOD_NS})
        end
      end

      def detach
        board.servo_toggle(pin, :off) if board.platform == :arduino
      end

      def position=(value)
        value = value % 180 unless value == 180

        microseconds = ((value.to_f / 180) * (max - min)) + min
        write_microseconds(microseconds)

        @state = value
      end

      def speed=(value)
        raise 'invalid speed value' if value > 100 || value < -100

        microseconds = (((value.to_f + 100) / 200) * (max - min)) + min
        write_microseconds(microseconds)

        @state = value
      end

      alias :angle=   :position=
      alias :angle    :state
      alias :position :state
      alias :speed    :state

      def write_microseconds(value)
        raise 'invalid microsecond value' if value > max || value < min
        if board.platform == :arduino
          board.servo_write(pin, value)
        else
          board.pwm_write(pin, (value * 1000.0).round)
        end
      end
    end
  end
end
