# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
DIGITAL_IO_FILES = [
  [:Input,          "input"],
  [:Output,         "output"],
  [:Button,         "button"],
  [:Relay,          "relay"],
  [:RotaryEncoder,  "rotary_encoder"],
  [:PCF8574,        "pcf8574"],
]

# On mruby, define this early since bit-bang I2C, SPI and 1-Wire depend on it.
DIGITAL_IO_EARLY_FILES = [
  [:CBitBang, "c_bit_bang"],
]

module Denko
  module DigitalIO
    (DIGITAL_IO_EARLY_FILES + DIGITAL_IO_FILES).each do |file|
      file_path = "#{__dir__}/digital_io/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
