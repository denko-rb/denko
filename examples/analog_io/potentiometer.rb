#
# Example for a potentiometer.
#
require 'bundler/setup'
require 'denko'

PIN = :A0

board = Denko::Board.new(Denko::Connection::Serial.new)
pot = Denko::AnalogIO::Potentiometer.new(pin: PIN, board: board)

# Tell connected Board to send a value every 8ms (default), and enable smoothing.
pot.listen
pot.smoothing = true

last_percent = nil
pot.on_data do |reading|
  # Map reading to a decimal between 0 and 1.
  fraction = reading / board.adc_high.to_f

  # Linearization hack for audio taper potentiometers.
  # Adjust k for different tapers. This was an A500K.
  k = 5
  linearized = (fraction * (k + 1)) / ((k * fraction) + 1)
  # Use this for linear potentiometers instead.
  # linearized = fraction

  percent = (linearized * 100).round
  unless percent == last_percent
    puts "Potentiometer: #{percent.to_s.rjust(3, " ")}%"
    last_percent = percent
  end
end

sleep
