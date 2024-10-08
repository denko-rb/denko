#
# Example 4: LED Brightness and PWM
#
require 'bundler/setup'
require 'denko'

# Set up the board, connecting with serial over USB
board = Denko::Board.new(Denko::Connection::Serial.new)

#
# LEDs don't change brightness much with voltage, but we can vary it with a
# technique called PWM. PWM sets up a fast (500Hz+) wave on the LED pin. Then we
# set a duty cycle, telling the LED what fraction of those cycles to be on for.
#
# Eg. 1 cycle on, 4 cycles off = 20% duty cycle.
# This happens so fast that it looks like 20% brightness to the naked eye.
#
# Depending on your board, some pins may not be PWM capable. Pin 13 on Arduinos
# isn't, so the earlier example was limited to on/off. There might be a wave
# symbol printed next to the pin number, but check your documentation.
#
# Note: If you have pins labeled "DAC", do not use them here. DACs generate steady
# analog voltages, not pulses.
#
# Set up LED on a PWM pin. See pwm_led.pdf in this folder for hook-up diagram.
#
led = Denko::LED.new(board: board, pin: 11)

# led.duty= sets duty cycle from 0 to 100, in percentage.
[0, 20, 40, 60, 80, 100].each do |duty|
  led.duty = duty
  print "LED at #{duty}% duty cycle. Press Enter..."; gets
end
puts

# Now let's add the potentiometer from the previous example to control it.
potentiometer = Denko::AnalogIO::Potentiometer.new(pin: 'A0', board: board)

# Helper method to calculate brightness.
def map_pot_value(value)
  # Map 10 bit value into 0 to 1 range.
  fraction = value / 1023.to_f

  # Linearization hack for audio taper potentiometers.
  # Adjust k for different tapers. This was an A500K.
  # k = 5
  # linearized = (fraction * (k + 1)) / ((k * fraction) + 1)

  # Use this for linear potentiometers instead.
  linearized = fraction

  # x100 to get percentage out of 100.
  (linearized * 100).round
end

# Callback to change brightness.
potentiometer.on_change do |value|
  duty     = map_pot_value(value)
  led.duty = duty
  print "LED brightness: #{duty}%  \r"
end

puts "Turn potentiometer to control the LED brightness. Press Ctrl+C to exit..."
sleep
