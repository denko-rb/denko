module Denko
  module UART
    autoload :Hardware, "#{__dir__}/uart/hardware"
    autoload :BitBang,  "#{__dir__}/uart/bit_bang"
  end
end
