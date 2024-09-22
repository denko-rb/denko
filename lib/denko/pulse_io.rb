module Denko
  module PulseIO
    autoload :PWMOutput,    "#{__dir__}/pulse_io/pwm_output"
    autoload :Buzzer,       "#{__dir__}/pulse_io/buzzer"
    autoload :IROutput,     "#{__dir__}/pulse_io/ir_output"
  end
end
