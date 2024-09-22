module Denko
  module PulseIO
    autoload :PWMOutput,    "#{__dir__}/pulse_io/pwm_output"
    autoload :Buzzer,       "#{__dir__}/pulse_io/buzzer"
    autoload :IROut,        "#{__dir__}/pulse_io/ir_out"
  end
end
