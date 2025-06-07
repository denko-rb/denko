require_relative "display/font"

# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
DISPLAY_FILES = [
  # Character Displays
  [:HD44780, "hd44780"],

  # Pixel display mixins and helpers
  [:PixelCommon,      "pixel_common"],
  [:SPICommon,        "spi_common"],
  [:SPIEPaperCommon,  "spi_epaper_common"],
  [:Canvas,           "canvas"],

  # OLEDs
  [:MonoOLED, "mono_oled"],
  [:SSD1306,  "ssd1306"],
  [:SH1106,   "sh1106"],
  [:SH1107,   "sh1107"],

  # LCDs
  [:PCD8544,  "pcd8544"],
  [:ST7302,   "st7302"],
  [:ST7565,   "st7565"],

  # E-paper
  [:IL0373,   "il0373"],
  [:SSD168X,  "ssd168x"],
  [:SSD1680,  "ssd1680"],
  [:SSD1681,  "ssd1681"],
]

module Denko
  module Display
    DISPLAY_FILES.each do |file|
      file_path = "#{__dir__}/display/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
