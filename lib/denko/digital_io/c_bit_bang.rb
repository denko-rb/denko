module Denko
  module DigitalIO
    class CBitBang
      include Behaviors::InputPin
      include Behaviors::Callbacks

      # This is purely to purely to force initialize validation
      # for any pins being used by C libraries that bit-bang.
    end
  end
end
