module Denko
  module DigitalIO
    class Relay < Output
      alias :open  :off
      alias :close :on
    end
  end
end
