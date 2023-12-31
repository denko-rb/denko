#
# Example 1: Controlling an LED
#
require 'bundler/setup'
require 'denko'

# If the board is plugged into a USB port, we can connect with serial over USB.
connection = Denko::Connection::Serial.new

# Create a new board object, giving the connection.
board = Denko::Board.new(connection)

#
# Create an LED object, giving the board, and the pin that the positive
# leg of the LED is connected to. The longer leg is usually positive.
#
# See led.pdf in this folder for a hook-up diagram.
# Use a current limiting resistor with external LEDs to protect them.
#
# The on-board LED can also be used. It is connected to pin 13 on most Arduinos,
# but can vary for other boards. The symbol :LED_BUILTIN should map to the right pin.
# If it doesn't, change it to the pin number from your board's documentation.
#
# Note: Some boards use an addressable LED on-board. In those cases, connect an external
# LED and use its pin for this example instead.
#
led = Denko::LED.new(board: board, pin: :LED_BUILTIN)

# Now we can make it blink.
puts "Blinking every half second..."

#
# A digital output can only have one of two states:
# 1 / high / on
# 0 / low / off
# We can use led.digital_write to set it directly, or named convenience methods.
# These 3 lines all do the same thing: turn on, wait half a second, turn off.
#
led.digital_write(1); sleep 0.5; led.digital_write(0)
led.high;             sleep 0.5; led.low
led.on;               sleep 0.5; led.off

#
# led.toggle will set it to the opposite state each time it's called.
# Keep it blinking for 3 more seconds using #toggle.
#
6.times do
  led.toggle
  sleep 0.5
end

#
# What if we want to blink in the background?
#
# led.blink runs in a separate thread, managed by the led, and doesn't block the
# main thread. Give it the blink interval in seconds.
#
led.blink 0.5
puts "Blinking in the background... Hello from the main thread!"
sleep 3

#
# Calling a method that sets the state (#digital_write, #high, #low, #on, #off)
# automatically stops the blink thread.
#
puts "Turning off for 2 seconds..."
led.off
sleep 2

# Blink faster indefinitely.
puts "Blinking faster forever... (Press Ctrl+C to exit)"
led.blink 0.1
sleep
