module Denko
  module LED
    class Base < PulseIO::PWMOutput
      def blink(interval=0.5)
        self.blink_interval = interval
        threaded_loop do
          toggle
          sleep @blink_interval
        end
      end

      def blink_interval=(interval)
        @blink_interval = interval
      end
      attr_reader :blink_interval
    end
  end
end
