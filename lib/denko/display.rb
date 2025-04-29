module Denko
  module Display
    autoload :DCPin,    "#{__dir__}/display/dc_pin"
    autoload :ResetPin, "#{__dir__}/display/reset_pin"
    autoload :HD44780,  "#{__dir__}/display/hd44780"
    autoload :Canvas,   "#{__dir__}/display/canvas"
    autoload :MonoOLED, "#{__dir__}/display/mono_oled"
    autoload :SSD1306,  "#{__dir__}/display/ssd1306"
    autoload :SH1106,   "#{__dir__}/display/sh1106"
    autoload :SH1107,   "#{__dir__}/display/sh1107"
    autoload :ST7302,   "#{__dir__}/display/st7302"
    autoload :ST7565,   "#{__dir__}/display/st7565"
  end
end
