module Denko
  module Motor
    class Servo
      include Behaviors::Component
      include Behaviors::SinglePin
      include Behaviors::Threaded

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
        board.servo_toggle(pin, :on, min: min, max: max)
      end

      def detach
        board.servo_toggle(pin, :off)
      end

      def position=(value)
        value = value % 180 unless value == 180

        microseconds = ((value.to_f / 180) * (max - min)) + min
        board.servo_write(pin, microseconds.round)

        self.state = value
      end

      def speed=(value)
        raise 'invalid speed value' if value > 100 || value < -100

        microseconds = (((value.to_f + 100) / 200) * (max - min)) + min
        board.servo_write(pin, microseconds.round)

        self.state = value
      end

      alias :angle=   :position=
      alias :angle    :state
      alias :position :state
      alias :speed    :state

      def write_microseconds(value)
        raise 'invalid microsecond value' if value > max || value < min
        board.servo_write(pin, value)
      end
    end
  end
end
