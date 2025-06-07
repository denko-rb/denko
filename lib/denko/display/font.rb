# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
FONT_FILES = [
  [:BMP_5X7,  "bmp_5x7"],
  [:BMP_6X8,  "bmp_6x8"],
  [:BMP_8X16, "bmp_8x16"],
]

module Denko
  module Display
    module Font
      FONT_FILES.each do |file|
        file_path = "#{__dir__}/font/#{file[1]}"
        if file[0]
          autoload file[0], file_path
        else
          require file_path
        end
      end
    end
  end
end
