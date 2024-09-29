module Denko
  module DigitalIO
    class CBitBang
      include Behaviors::SinglePin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle

      # This is purely to force initialize validation for any pins
      # being used by C libraries that bit-bang.
      before_initialize do
        params[:mode] ||= :input
      end
    end
  end
end
