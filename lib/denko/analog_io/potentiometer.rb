module Denko
  module AnalogIO
    class Potentiometer < Input
      include Behaviors::Component

      after_initialize do
        # Enable smoothing and start listening immediately at ~125 Hz.
        self.smoothing = true
        listen(8)
      end
    end
  end
end
