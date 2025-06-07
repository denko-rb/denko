# Represent files to be autoloaded in CRuby as an Array.
# This allows Mruby::Build to parse and preload them instead.
RTC_FILES = [
  [:DS3231, "ds3231"],
]

module Denko
  module RTC
    RTC_FILES.each do |file|
      file_path = "#{__dir__}/rtc/#{file[1]}"
      if file[0]
        autoload file[0], file_path
      else
        require file_path
      end
    end
  end
end
