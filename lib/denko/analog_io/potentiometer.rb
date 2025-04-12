module Denko
  module AnalogIO
    class Potentiometer < Input
      after_initialize do
        @divider ||= params[:divider] || 8
      end
    end
  end
end
