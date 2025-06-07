# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
LED_FILES = [
  [nil,           "base"],
  [:RGB,          "rgb"],
  [:SevenSegment, "seven_segment"],
  [:WS2812,       "ws2812"],
  [:APA102,       "apa102"],
]

module Denko
  module LED
    LED_FILES.each do |file|
      file_path = "#{__dir__}/led/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
