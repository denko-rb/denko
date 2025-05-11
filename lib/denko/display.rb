module Denko
  module Display
    # Character Displays
    autoload :HD44780,  "#{__dir__}/display/hd44780"

    # Pixel display mixins and helpers
    autoload :PixelCommon,  "#{__dir__}/display/pixel_common"
    autoload :SPICommon,    "#{__dir__}/display/spi_common"
    autoload :Canvas,       "#{__dir__}/display/canvas"

    # OLEDs
    autoload :MonoOLED, "#{__dir__}/display/mono_oled"
    autoload :SSD1306,  "#{__dir__}/display/ssd1306"
    autoload :SH1106,   "#{__dir__}/display/sh1106"
    autoload :SH1107,   "#{__dir__}/display/sh1107"

    # LCDs
    autoload :PCD8544,  "#{__dir__}/display/pcd8544"
    autoload :ST7302,   "#{__dir__}/display/st7302"
    autoload :ST7565,   "#{__dir__}/display/st7565"

    # E-paper
    autoload :SSD1681,  "#{__dir__}/display/ssd1681"
    autoload :SSD1680,  "#{__dir__}/display/ssd1680"
  end
end
