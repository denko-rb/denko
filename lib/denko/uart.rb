# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
UART_FILES = [
  [nil,        "common"],
  [:Hardware,  "hardware"],
  [:BitBang,   "bit_bang"],
]

module Denko
  module UART
    UART_FILES.each do |file|
      file_path = "#{__dir__}/uart/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
