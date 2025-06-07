# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
I2C_FILES = [
  [:BusCommon,  "bus_common"],
  [:Bus,        "bus"],
  [:BitBang,    "bit_bang"],
  [:Peripheral, "peripheral"],
]

module Denko
  module I2C
    I2C_FILES.each do |file|
      file_path = "#{__dir__}/i2c/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
