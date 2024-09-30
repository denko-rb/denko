module Denko
  module Motor
    class L298
      include Behaviors::MultiPin
      include Behaviors::Lifecycle

      attr_reader :speed

      def initialize_pins(options={})
        proxy_pin :direction1,  DigitalIO::Output
        proxy_pin :direction2,  DigitalIO::Output
        proxy_pin :enable,      PulseIO::PWMOutput
      end

      after_initialize do
        off
      end

      def speed=(value)
        enable.duty = value
        @speed = value
      end

      def forward(value=nil)
        direction1.high
        direction2.low
        self.speed = value if value
      end

      def reverse(value=nil)
        direction1.low
        direction2.high
        self.speed = value if value
      end

      def idle
        direction1.low
        direction2.low
        self.speed = 0
      end
      alias :off :idle

      def brake
        direction1.high
        direction2.high
        self.speed = 100
      end
    end
  end
end
