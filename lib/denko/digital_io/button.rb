module Denko
  module DigitalIO
    class Button < Input
      before_initialize do
        params[:divider] = 1
      end

      alias :down :on_low
      alias :up   :on_high
    end
  end
end
