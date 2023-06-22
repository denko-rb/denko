module Denko
  module OneWire
    autoload :Constants,      "#{__dir__}/one_wire/constants"
    autoload :Helper,         "#{__dir__}/one_wire/helper"
    autoload :BusEnumerator,  "#{__dir__}/one_wire/bus_enumerator"
    autoload :Bus,            "#{__dir__}/one_wire/bus"
    autoload :Peripheral,     "#{__dir__}/one_wire/peripheral"
  end
end
