# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
SPI_FILES = [
  [:BusCommon,      "bus_common"],
  [:Bus,            "bus"],
  [:BitBang,        "bit_bang"],
  [:ChipSelect,     "peripheral"],
  [:Peripheral,     "peripheral"],
  [:Register,       "register"],
  [:InputRegister,  "input_register"],
  [:OutputRegister, "output_register"],
]

module Denko
  module SPI
    SPI_FILES.each do |file|
      file_path = "#{__dir__}/spi/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
