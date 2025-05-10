#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'denko'

# These pins match the SainSmart LCD Keypad Shield for Arduino boards.
RS = 8
EN = 9
D4 = 4
D5 = 5
D6 = 6
D7 = 7

board = Denko::Board.new(Denko::Connection::Serial.new)
lcd   = Denko::Display::HD44780.new  board: board,
                                     pins: { rs: RS, enable: EN, d4: D4, d5: D5, d6: D6, d7: D7 },
                                     cols: 16,
                                     rows: 2

# Bitmap for a custom character. 5 bits wide x 8 high.
# Useful for generating these: https://omerk.github.io/lcdchargen/
heart = [	0b00000,
        	0b00000,
        	0b01010,
        	0b11111,
        	0b11111,
        	0b01110,
        	0b00100,
        	0b00000 ]

# Define the character in CGRAM address 2. 0-7 are usable.
lcd.create_char(2, heart)

# Need to call home/clear/text_cursor so we go back to writing DDRAM.
lcd.home

# End the first line with the heart by writing its CGRAM address.
lcd.text "Hello World!   "
lcd.write(2)

# Display a clock on second line, updating approximately every second.
loop do
  lcd.text_cursor 0,1
  lcd.text(Time.now.strftime("%I:%M:%S"))
  sleep 1
end
