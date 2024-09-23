module Denko
  module PulseIO
    class Buzzer < PWMOutput
      include Behaviors::Component

      def initialize_pins(options={})
        options[:mode] = :output_pwm
        super(options)
      end

      after_initialize do
        low
      end

      # Duration is in mills
      def tone(frequency, duration=nil)
        board.tone(pin, frequency, duration)
      end

      def no_tone
        board.no_tone(pin)
      end

      # Kill the thread if running, and send no_tone.
      def stop
        stop_thread
        board.no_tone(pin)
      end
      alias :off :stop
    end
  end
end
