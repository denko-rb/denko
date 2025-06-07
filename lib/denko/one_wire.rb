# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
ONE_WIRE_FILES = [
  [:Constants,      "constants"],
  [:Helper,         "helper"],
  [:BusEnumerator,  "bus_enumerator"],
  [:Bus,            "bus"],
  [:Peripheral,     "peripheral"],
]

module Denko
  module OneWire
    ONE_WIRE_FILES.each do |file|
      file_path = "#{__dir__}/one_wire/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
