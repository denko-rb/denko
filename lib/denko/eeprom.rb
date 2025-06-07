# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
EEPROM_FILES = [
  [:Board,  "board"],
  [:AT24C,  "at24c"],
]

module Denko
  module EEPROM
    EEPROM_FILES.each do |file|
      file_path = "#{__dir__}/eeprom/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
