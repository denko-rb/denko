module Denko
  module SPI
    autoload :BusCommon,      "#{__dir__}/spi/bus_common"
    autoload :Bus,            "#{__dir__}/spi/bus"
    autoload :BitBang,        "#{__dir__}/spi/bit_bang"
    autoload :ChipSelect,     "#{__dir__}/spi/peripheral"
    autoload :Peripheral,     "#{__dir__}/spi/peripheral"
    autoload :BaseRegister,   "#{__dir__}/spi/base_register"
    autoload :InputRegister,  "#{__dir__}/spi/input_register"
    autoload :OutputRegister, "#{__dir__}/spi/output_register"
  end
end
