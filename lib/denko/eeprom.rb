module Denko
  module EEPROM
    autoload :Board,   "#{__dir__}/eeprom/board"
    autoload :AT24C,   "#{__dir__}/eeprom/at24c"
  end
end
