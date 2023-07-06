require "minitest/autorun"

if RUBY_ENGINE == "ruby"
  require 'simplecov'
  SimpleCov.start do
    track_files "lib/**/*.rb"
    add_filter "test"
    add_filter "lib/denko_cli"
  end
end

require 'bundler/setup'
require 'denko'

# Touch each class to trigger auto load for simplecov.
# Analog IO
Denko::AnalogIO::ADS1118
Denko::AnalogIO::Input
Denko::AnalogIO::Output
Denko::AnalogIO::Potentiometer
Denko::AnalogIO::Sensor

# Behaviors
# Not needed, since every behavior will be included by at least one class.

# Board
# BoardMock inherits from Denko::Board

# Connection
Denko::Connection::Serial
Denko::Connection::TCP

# Digital IO
Denko::DigitalIO::Button
Denko::DigitalIO::Input
Denko::DigitalIO::Output
Denko::DigitalIO::Relay
Denko::DigitalIO::RotaryEncoder

# Display
Denko::Display::Canvas
Denko::Display::HD44780
Denko::Display::SSD1306

# EEPROM
Denko::EEPROM::BuiltIn

# I2C
Denko::I2C::Bus
Denko::I2C::Peripheral

# LED
Denko::LED::APA102
Denko::LED::Base
Denko::LED::RGB
Denko::LED::SevenSegment
Denko::LED::WS2812

# Motor
Denko::Motor::L298
Denko::Motor::Servo
Denko::Motor::Stepper

# OneWire
Denko::OneWire::Bus
Denko::OneWire::Peripheral
Denko::OneWire::Helper

# Pulse IO
Denko::PulseIO::Buzzer
Denko::PulseIO::IRTransmitter
Denko::PulseIO::PWMOutput

# RTC
Denko::RTC::DS3231

# Sensor
Denko::Sensor::Temperature
Denko::Sensor::Humidity
Denko::Sensor::BME280
Denko::Sensor::BMP280
Denko::Sensor::DHT
Denko::Sensor::DS18B20
Denko::Sensor::HTU21D

# SPI
Denko::SPI::BaseRegister
Denko::SPI::BitBang
Denko::SPI::Bus
Denko::SPI::InputRegister
Denko::SPI::OutputRegister

# UART
Denko::UART::BitBang

# Helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end
  ACK = "SAMD_ZERO,0.13.0,528,1024,32"

  # Some test redefine RUBY_PLATFORM. Save the original to reset it.
  ORIGINAL_RUBY_PLATFORM = RUBY_PLATFORM
end

# Taken from: https://gist.github.com/moertel/11091573
def suppress_output
  begin
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    if Constants::ORIGINAL_RUBY_PLATFORM.match(/mswin|mingw/i)
      $stderr.reopen('NUL:')
      $stdout.reopen('NUL:')
    else
      $stderr.reopen(File.new('/dev/null', 'w'))
      $stdout.reopen(File.new('/dev/null', 'w'))
    end
    retval = yield
  rescue Exception => e
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
    raise e
  ensure
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
  end
  retval
end

class ConnectionMock
  def add_observer(board); true; end
  def read; true; end
  def write(str); true; end
  def handshake
    Constants::ACK
  end
end

class BoardMock < Denko::Board
  def initialize
    super(ConnectionMock.new)
    @read_injection_mutex = Mutex.new
  end

  WAITING_ON_READ_KEYS = [:read, :bus_controller, :board_proxy, :force_udpate]

  def component_exists_for_pin(pin)
    self.components.each do |component|
      return component if component.pin == pin
    end
    false
  end

  def waiting_on_read(component)
    WAITING_ON_READ_KEYS.each do |key|
      return true if component.callbacks[key]
    end
    false
  end

  #
  # Inject a message into the Board instance as if it were coming from the phsyical board.
  # Use this to mock input data for the blocking #read pattern in the Reader behavior.
  #
  def inject_read_for_pin(pin, message)
    Thread.new do
      # Wait for a component to be added.
      component = false
      while !component
        sleep(0.001)
        component = component_exists_for_pin(pin)
      end

      # Wait for the component to have a "WAITING_ON_READ" callback.
      sleep(0.001) while !component.callback_mutex
      sleep(0.001) while !component.callbacks
      sleep(0.001) while !waiting_on_read(component)

      # Then inject the message.
      @read_injection_mutex.synchronize do
        self.update("#{pin}:#{message}")
      end
    end
  end

  #
  # Inject a message into the Board instance as if it were coming from the phsyical board.
  # Use this to mock input data for the blocking #read pattern in the Reader behavior.
  #
  def inject_read_for_component(component, pin, message)
    Thread.new do
      # Wait for the component to have a "WAITING_ON_READ" callback.
      sleep(0.001) while !component.callback_mutex
      sleep(0.001) while !component.callbacks
      sleep(0.001) while !waiting_on_read(component)

      # Then inject the message.
      @read_injection_mutex.synchronize do
        self.update("#{pin}:#{message}")
      end
    end
  end
end

module TestPacker
  def pack(*args, **kwargs)
    Denko::Message.pack(*args, **kwargs)
  end
end

# Speed up tests which use long delays.
module Denko
  module OneWire
    class Bus
      def sleep(time)
        super(0.001)
      end
    end
  end
  module LED
    class SevenSegment
      def sleep(time)
        super(0.001)
      end
    end
  end
end
