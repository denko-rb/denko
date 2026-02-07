# Helpers needed during loading.
require_relative 'denko/helpers'

# Denko - Electronics Programming in Ruby
#
# Program real-life electronics in Ruby. LEDs, buttons, sensors (and more)
# work just like any Ruby object.
#
# Denko provides a Ruby API for controlling physical peripherals while
# abstracting hardware and software complexity. It supports connected
# microcontrollers, single-board computers, and mruby on embedded systems.
#
# @example Connect to a board and blink an LED
#   board = Denko::Board.new(Denko::Connection::Serial.new)
#   led = Denko::LED::Base.new(board: board, pin: 13)
#   led.blink(0.5)
#
# @example Read a sensor
#   board = Denko::Board.new(Denko::Connection::Serial.new)
#   sensor = Denko::Sensor::DHT22.new(board: board, pin: 7)
#   sensor.read
#   puts "Temperature: #{sensor.temperature}°C"
#
# @see https://github.com/denko-rb/denko
# @author vickash, Austinbv
#
module Denko
end

unless Denko.in_mruby_build?
  Thread.abort_on_exception = true

  require 'bcd'

  module Denko
    def self.root
      File.expand_path '../..', __FILE__
    end
  end
end

# Early shared behavior
require_relative 'denko/version'
require_relative 'denko/behaviors'

# Denko::Board implementation for connected microcontrollers
unless Denko.in_mruby_build?
  require_relative 'denko/message'
  require_relative 'denko/connection'
  require_relative 'denko/board'
  # Diagnostics
  require_relative 'denko/connection/binary_echo'
end

# Basic IO peripherals
require_relative 'denko/digital_io'
require_relative 'denko/analog_io'
require_relative 'denko/pulse_io'

# Buses and interfaces
require_relative 'denko/uart'
require_relative 'denko/spi'
require_relative 'denko/i2c'
require_relative 'denko/one_wire'

# Everything else
require_relative 'denko/display'
require_relative 'denko/eeprom'
require_relative 'denko/led'
require_relative 'denko/motor'
require_relative 'denko/rtc'
require_relative 'denko/sensor'
