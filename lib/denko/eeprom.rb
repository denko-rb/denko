module Denko
  module EEPROM
    autoload :BuiltIn, "#{__dir__}/eeprom/built_in"
    autoload :AT24C,   "#{__dir__}/eeprom/at24c"
  end
end
