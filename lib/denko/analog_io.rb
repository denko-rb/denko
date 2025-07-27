# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
ANALOG_IO_FILES = [
  [:InputHelper,    "input_helper"],
  [:Input,          "input"],
  [:Output,         "output"],
  [:Potentiometer,  "potentiometer"],
  [:Joystick,       "joystick"],
  [:ADKeyboard,     "adkeyboard"],
  [:ADS111X,        "ads111x"],
  [:ADS1100,        "ads1100"],
  [:ADS1115,        "ads1115"],
  [:ADS1118,        "ads1118"],
]

module Denko
  module AnalogIO
    ANALOG_IO_FILES.each do |file|
      file_path = "#{__dir__}/analog_io/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
