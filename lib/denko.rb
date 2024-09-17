Thread.abort_on_exception = true

module Denko
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.cruby?
    RUBY_ENGINE == "ruby"
  end
end

# For method delegation.
require 'forwardable'

# Bypass mutexes where possible for CRuby.
require_relative 'denko/mutex_stub'

# Component support stuff.
require_relative 'denko/version'
require_relative 'denko/behaviors'
require_relative 'denko/fonts'

# Board stuff.
require_relative 'denko/message'
require_relative 'denko/connection'
require_relative 'denko/board'

# Basic IO components.
require_relative 'denko/digital_io'
require_relative 'denko/analog_io'
require_relative 'denko/pulse_io'

# Buses and interfaces.
require_relative 'denko/uart'
require_relative 'denko/spi'
require_relative 'denko/i2c'
require_relative 'denko/one_wire'

# Everything else.
require_relative 'denko/display'
require_relative 'denko/eeprom'
require_relative 'denko/led'
require_relative 'denko/motor'
require_relative 'denko/rtc'
require_relative 'denko/sensor'

# Diagnostics
require_relative 'denko/connection/binary_echo'
