# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
MOTOR_FILES = [
  [:Servo,  "servo"],
  [:A3967,  "a3967"],
  [:L298,   "l298"],
]

module Denko
  module Motor
    MOTOR_FILES.each do |file|
      file_path = "#{__dir__}/motor/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
