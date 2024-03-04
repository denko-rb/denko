module Denko
  module AnalogIO
    autoload :Input,          "#{__dir__}/analog_io/input"
    autoload :Output,         "#{__dir__}/analog_io/output"
    autoload :Potentiometer,  "#{__dir__}/analog_io/potentiometer"
    autoload :ADS111X,        "#{__dir__}/analog_io/ads111x"
    autoload :ADS1100,        "#{__dir__}/analog_io/ads1100"
    autoload :ADS1115,        "#{__dir__}/analog_io/ads1115"
    autoload :ADS1118,        "#{__dir__}/analog_io/ads1118"
  end
end
