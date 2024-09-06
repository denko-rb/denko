module Denko
  module Display
    autoload :Canvas,   "#{__dir__}/display/canvas"
    autoload :HD44780,  "#{__dir__}/display/hd44780"
    autoload :SSD1306,  "#{__dir__}/display/ssd1306"
    autoload :SH1106,   "#{__dir__}/display/sh1106"
  end
end
