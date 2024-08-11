module Denko
  module I2C
    autoload :Bus,        "#{__dir__}/i2c/bus"
    autoload :BitBang,    "#{__dir__}/i2c/bit_bang"
    autoload :Peripheral, "#{__dir__}/i2c/peripheral"
  end
end
