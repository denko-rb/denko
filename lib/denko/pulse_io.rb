# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
PULSE_IO_FILES = [
  # Pin and component setup stuff
  [:PWMOutput, "pwm_output"],
  [:Buzzer,    "buzzer"],
  [:IROutput,  "ir_output"],
]

module Denko
  module PulseIO
    PULSE_IO_FILES.each do |file|
      file_path = "#{__dir__}/pulse_io/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
