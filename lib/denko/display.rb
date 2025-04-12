module Denko
  module Display
    autoload :HD44780,  "#{__dir__}/display/hd44780"
    autoload :Canvas,   "#{__dir__}/display/canvas"
    autoload :MonoOLED, "#{__dir__}/display/mono_oled"
    autoload :SSD1306,  "#{__dir__}/display/ssd1306"
    autoload :SH1106,   "#{__dir__}/display/sh1106"
    autoload :SH1107,   "#{__dir__}/display/sh1107"
  end
end
