#
# Example 2: Using a Button
#
require 'bundler/setup'
require 'denko'

# Set up the board, connecting with serial over USB.
board = Denko::Board.new(Denko::Connection::Serial.new)

#
# Create an object for a momentary button, giving the board, and the pin that
# the ungrounded side of the button is connected to.
#
# `mode: :input_pullup` keeps the input pin high (logical 1) when the
# button is not pressed. Without this (or an external pullup resistor), the pin
# might float between 0 and 1, giving incorrect readings. When the button is
# pressed, it pulls the input pin down to ground (0).
#
# See button.pdf in this folder for a hook-up diagram.
#
button = Denko::DigitalIO::Button.new(board: board, pin: 7, mode: :input_pullup)

#
# As soon as a Button (or any DigitalInput) is created, the board starts
# listening for changes to the physical button. When that happens, our button
# object is notified. To catch these notifications, we have to use a callback.
# button.add_callback saves a block of code to run each time the button state changes.
#
# The callback below checks if the state is 0 (the button went from up to down),
# then counts and prints the number of times pressed.
#
presses = 0
button.add_callback(:count_presses) do |state|
  if state == 0
    presses = presses + 1
    puts "Button press ##{presses}"
  end
end

# Wait for the button to be pressed 3 times.
puts "Press button 3 times to continue..."
sleep 0.005 while presses < 3

# Button keeps its callbacks in a Hash. We can be specific and use keys to add and remove.
button.remove_callback(:count_presses)

# Or remove them all. Either way, the block above won't run anymore.
button.remove_callbacks

#
# button.down and button.up add callbacks that automatically check state for you.
#
# #down runs only when state goes from high (1) to low (0).
# #up runs only when state goes from low (0) to high (1).
#
# We can use them to control the internal LED from example 1.
#
led = Denko::LED.new(board: board, pin: 13)

button.up   { led.off }
button.down { led.on }

puts "Press the button to turn on the LED... (Ctrl+C to exit)"

sleep
