#
# Example using a KY-040 (30 detent) rotary encoder as a mac volume control.
#
require 'bundler/setup'
require 'denko'

PIN_A = 4
PIN_B = 5

board   = Denko::Board.new(Denko::Connection::Serial.new)
encoder = Denko::DigitalIO::RotaryEncoder.new  board: board,
                                               pins:  { a: PIN_A, b: PIN_B }

# Set up a pseudo terminal with osascript (AppleScript) in interactive mode.
# Calling a separate script each update is too slow.
class AppleVolumeWrapper
  require 'pty'
  require 'expect'

  def initialize
    @in, @out, pid = PTY.spawn('osascript -i')
    @in.expect(/>> /) # Terminal ready.
  end

  def get
    @out.write("output volume of (get volume settings)\r\n")
    @in.expect(/=> (\d+)\r\n/)[1].to_i
  end

  def set(value)
    @out.write("set volume output volume #{value}\r\n")
    @in.expect(/>> /)
  end
end

volumeWrapper= AppleVolumeWrapper.new
# volumeWrapper.get can return imprecise values.
# Display those, but keep exact value in this variable.
volume = volumeWrapper.get
puts "Current volume: #{volume}%"

encoder.add_callback do |update|
  # update[:change] is always either +1 or -1.
  volume = volume += update[:change]
  volume = 0 if volume < 0
  volume = 100 if volume > 100

  volumeWrapper.set(volume)
  current_volume = volumeWrapper.get
  puts "Current volume: #{current_volume}%"
end

sleep
