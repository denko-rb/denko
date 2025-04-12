module Denko
  module PulseIO
    class Buzzer < PWMOutput
      include Behaviors::Lifecycle

      before_initialize do
        params[:mode] ||= :output_pwm
      end

      after_initialize do
        board.no_tone(pin)
      end

      # Duration is in mills
      def tone(frequency, duration=nil)
        board.tone(pin, frequency, duration)
      end

      def no_tone
        board.no_tone(pin)
      end

      alias :stop :no_tone
      alias :off  :no_tone
    end
  end
end
