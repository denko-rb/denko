module Denko
  module Sensor
    class HCSR04
      include Behaviors::Lifecycle
      include Behaviors::MultiPin
      include Behaviors::Poller

      # Speed of sound in meters per second.
      SPEED_OF_SOUND = 343.0

      def initialize_pins
        proxy_pin :trigger, DigitalIO::Output
        proxy_pin :echo,    DigitalIO::Input
      end

      after_initialize do
        # Avoid generating extraneous alerts when used with Denko::PiBoard.
        echo.stop

        # Receive values from echo pin.
        echo.add_callback { |data| self.update(data) }
      end

      def _read
        board.hcsr04_read(echo.pin, trigger.pin)
      end

      def pre_callback_filter(us)
        # Data is microseconds roundtrip time. Convert to mm.
        um = (us/2) * SPEED_OF_SOUND
        mm = um / 1000.0
      end
    end
  end
end
