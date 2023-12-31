module Denko
  module LED
    autoload :Base,         "#{__dir__}/led/base"
    autoload :RGB,          "#{__dir__}/led/rgb"
    autoload :SevenSegment, "#{__dir__}/led/seven_segment"
    autoload :WS2812,       "#{__dir__}/led/ws2812"
    autoload :APA102,       "#{__dir__}/led/apa102"

    def self.new(options={})
      self::Base.new(options)
    end
  end
end
