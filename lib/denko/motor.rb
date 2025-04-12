module Denko
  module Motor
    autoload :Servo,    "#{__dir__}/motor/servo"
    autoload :A3967,    "#{__dir__}/motor/a3967"
    autoload :L298,     "#{__dir__}/motor/l298"
  end
end
