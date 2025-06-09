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
Denko::EEPROM::Board

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
Denko::Motor::A3967

# OneWire
Denko::OneWire::Bus
Denko::OneWire::Peripheral
Denko::OneWire::Helper

# Pulse IO
Denko::PulseIO::Buzzer
Denko::PulseIO::IROutput
Denko::PulseIO::PWMOutput

# RTC
Denko::RTC::DS3231

# Sensor
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
  # Imaginary handshake ack from the board. Not a real SAMD_ZERO device.
  # Serial buffer = 256
  # Aux size = 528
  # EEPROM size = 1024
  # I2C buffer = 32
  ACK = "SAMD_ZERO,0.13.0,256,528,1024,32"

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
  def remote_buffer_size=(size)
    @remote_buffer_size = size
  end
end

class BoardMock < Denko::Board
  def initialize(connection=nil, options={})
    super(ConnectionMock.new)
  end

  def is_a_register?
    false
  end

  #
  # Reads are async, in a background thread. This is a way to detect when a Component has
  # initiated a read, and is waiting on a response that will eventually call its #update.
  #
  WAITING_ON_READ_KEYS = [:read, :read_raw, :bus_controller, :board_proxy, :force_update]

  def read_injection_mutex
    @read_injection_mutex ||= Mutex.new
  end

  def expects_reading?(component)
    WAITING_ON_READ_KEYS.each { |key| return true if component.callbacks[key] }
    false
  end

  def wait_for_component_read(component)
    sleep(0.001) while !component.callbacks
    sleep(0.001) while !expects_reading?(component)
  end

  #
  # Inject a message that will call the Component#update directly after it reads,
  # bypassing Board. Use for testing above the Board interface.
  #
  def inject_component_update(component, data)
    Thread.new do
      wait_for_component_read(component)
      read_injection_mutex.synchronize { component.update(data) }
    end
  end

  #
  # We also want to inject readings at the pin or bus level, to test Board itself,
  # or for integration tests. This waits for a pin to have a Component attached to it.
  #
  def wait_for_component_on_pin(pin)
    component = false
    while !component
      sleep(0.001)
      component = single_pin_components[pin]
    end
    component
  end

  #
  # Inject a message into the Board instance as if coming from a pin on the phsyical board.
  # Use for testing Board internals, Board interface, and integration tests.
  #
  def inject_read_for_pin(pin, message)
    Thread.new do
      component = wait_for_component_on_pin(pin)
      wait_for_component_read(component)
      read_injection_mutex.synchronize do
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
