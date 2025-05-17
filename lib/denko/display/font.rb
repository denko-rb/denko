module Denko
  module Display
    module Font
      #
      # First 3 are adapted from:
      # https://github.com/lexus2k/ssd1306/blob/master/src/ssd1306_fonts.c
      #
      # MIT License
      #
      # Copyright (c) 2018-2019, Alexey Dynda
      #
      # Permission is hereby granted, free of charge, to any person obtaining a copy
      # of this software and associated documentation files (the "Software"), to deal
      # in the Software without restriction, including without limitation the rights
      # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      # copies of the Software, and to permit persons to whom the Software is
      # furnished to do so, subject to the following conditions:
      #
      # The above copyright notice and this permission notice shall be included in all
      # copies or substantial portions of the Software.
      #
      # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      # SOFTWARE.
      #
      # ssd1306xled_font6x8 is by Neven Boyanov
      # ssd1306xled_font8x16 is by Neven Boyanov
      #
      # @created: 2014-08-12
      # @author: Neven Boyanov
      #
      # Copyright (c) 2015 Neven Boyanov, Tinusaur Team. All Rights Reserved.
      # Distributed as open source software under MIT License, see LICENSE.txt file.
      # Please, as a favour, retain the link http://tinusaur.org to The Tinusaur Project.
      #
      # Source code available at: https://bitbucket.org/tinusaur/ssd1306xled
      #
      autoload :BMP_5X7,  "#{__dir__}/font/bmp_5x7"
      autoload :BMP_6X8,  "#{__dir__}/font/bmp_6x8"
      autoload :BMP_8X16, "#{__dir__}/font/bmp_8x16"
    end
  end
end
