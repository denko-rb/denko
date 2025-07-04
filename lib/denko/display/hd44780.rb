#
# Ruby implementation of Hitach HD44780 LCD support.
# Based on the Adafruit_LiquidCrystal library:
# https://github.com/adafruit/Adafruit_LiquidCrystal
#
module Denko
  module Display
    class HD44780
      include Behaviors::MultiPin
      include Behaviors::Lifecycle

      # Commands
      LCD_CLEARDISPLAY   = 0x01
      LCD_RETURNHOME     = 0x02
      LCD_ENTRYMODESET   = 0x04
      LCD_DISPLAYCONTROL = 0x08
      LCD_CURSORSHIFT    = 0x10
      LCD_FUNCTIONSET    = 0x20
      LCD_SETCGRAMADDR   = 0x40
      LCD_SETDDRAMADDR   = 0x80

      # Flags for display entry mode
      LCD_ENTRYRIGHT          = 0x00
      LCD_ENTRYLEFT           = 0x02
      LCD_ENTRYSHIFTINCREMENT = 0x01
      LCD_ENTRYSHIFTDECREMENT = 0x00

      # Flags for display on/off control
      LCD_DISPLAYON  = 0x04
      LCD_DISPLAYOFF = 0x00
      LCD_CURSORON   = 0x02
      LCD_CURSOROFF  = 0x00
      LCD_BLINKON    = 0x01
      LCD_BLINKOFF   = 0x00

      # Flags for display/cursor shift
      LCD_DISPLAYMOVE = 0x08
      LCD_CURSORMOVE  = 0x00
      LCD_MOVERIGHT   = 0x04
      LCD_MOVELEFT    = 0x00

      # Flags for function set
      LCD_8BITMODE = 0x10
      LCD_4BITMODE = 0x00
      LCD_2LINE    = 0x08
      LCD_1LINE    = 0x00
      LCD_5x10DOTS = 0x04
      LCD_5x8DOTS  = 0x00

      def data_lines
        @data_lines ||= 4
      end

      # Default to 16x2 display if columns and rows given.
      def columns
        @columns ||= params[:columns] || 16
      end

      def rows
        @rows ||= params[:rows] || 2
      end

      # Fuction set byte to set up the LCD. These OR'ed defaults == 0x00.
      def function
        @function ||= LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS
      end

      # Offset memory address when moving cursor.
      # Row 2 always starts at memory address 0x40.
      # For 4 line LCDs:
      #   Row 3 is immediately after row 1, +16 or 20 bytes, depending on columns.
      #   Row 4 is immediately after row 2, +16 or 20 bytes, depending on columns.
      def row_offsets
        @row_offsets ||= [0x00, 0x40, 0x00+columns, 0x40+columns]
      end

      # Start with cursor off and no cursor blink.
      def control
        @control ||= LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
      end

      def entry_mode
        @entry_mode ||= LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
      end

      attr_writer :columns, :rows, :function, :data_lines, :row_offsets, :control, :entry_mode

      def initialize_pins(options={})
        # All the required pins.
        [:rs, :enable, :d4, :d5, :d6, :d7].each do |symbol|
          proxy_pin(symbol, DigitalIO::Output)
        end

        # If any of d0-d3 was given, make them all non-optional.
        lower_bits_optional = (self.pins.keys & [:d0, :d1, :d2, :d3]).empty?
        [:d0, :d1, :d2, :d3].each do |symbol|
          proxy_pin(symbol, DigitalIO::Output, optional: lower_bits_optional)
        end

        # RW pin can be hardwired to GND, or given. Will be always pulled low.
        proxy_pin :rw, DigitalIO::Output, optional: true

        # Backlight can be hardwired, given here, or modeled as a separate component.
        # If HD44780 is on a digital register, and PWM is desired, use a separate component.
        proxy_pin :backlight, LED::Base, optional: true
      end

      after_initialize do
        # Switch to 8-bit mode if d0-d3 are present.
        if (d0 && d1 && d2 && d3)
          self.data_lines = 8
          self.function |= LCD_8BITMODE
        end

        # Set 2 line (row) mode if needed.
        self.function |= LCD_2LINE if (rows > 1)

        # Some 1 line displays can use a 5x10 font.
        self.function |= LCD_5x10DOTS if params[:tall_font] && (rows == 1)

        # Wait 50ms for power to be > 2.7V, then pull everything low.
        micro_delay(50000)
        enable.low; rs.low; rw.low if rw

        # Start in 4-bit mode.
        if data_lines == 4
          # Keep setting 8-bit mode until ready.
          command(0x03); micro_delay(4500)
          command(0x03); micro_delay(4500)
          command(0x03); micro_delay(150)

          # Set 4-bit mode.
          command(0x02)

        # Or start in 8 bit mode.
        else
          command(LCD_FUNCTIONSET | function)
          micro_delay(4500)
          command(LCD_FUNCTIONSET | function)
          micro_delay(150)
          command(LCD_FUNCTIONSET | function)
        end

        # Set functions (lines, font size, etc.).
        command(LCD_FUNCTIONSET | function)

        display_on
        clear
        backlight.on if backlight

        # Write entry mode.
        command(LCD_ENTRYMODESET | entry_mode)

        # Need this small delay to avoid garbage data on startup.
        sleep 0.05
      end

      def clear
        command(LCD_CLEARDISPLAY)
        micro_delay(2000)
      end

      def home
        command(LCD_RETURNHOME)
        micro_delay(2000)
      end

      def text_cursor(col, row)
        # Limit to the highest row, 0 indexed.
        row = (rows - 1) if row > (rows - 1)
        command(LCD_SETDDRAMADDR | (col + row_offsets[row]))
      end
      alias :move_to :text_cursor

      def text(str)
        str.each_byte { |b| write b }
      end

      #
      # Create a #key_on and #key_off method for each feature in this hash,
      # using the constant in the value to send a control signal.
      #
      # Eg. #display_on and #display_off.
      #
      CONTROL_TOGGLES = {
        "display" => LCD_DISPLAYON,
        "cursor"  =>  LCD_CURSORON,
        "blink"   =>  LCD_BLINKON,
      }
      CONTROL_TOGGLES.each_key do |key|
        define_method (key + "_off") do
          command LCD_DISPLAYCONTROL | (self.control &= ~CONTROL_TOGGLES[key])
        end
        define_method (key + "_on") do
          command LCD_DISPLAYCONTROL | (self.control |= CONTROL_TOGGLES[key])
        end
      end

      def left_to_right
        self.entry_mode |= LCD_ENTRYLEFT
        command(LCD_ENTRYMODESET | entry_mode)
      end

      def right_to_left
        self.entry_mode &= ~LCD_ENTRYLEFT
        command(LCD_ENTRYMODESET | entry_mode)
      end

      def scroll_left
        command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT)
      end

      def scroll_right
        command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT)
      end

      def autoscroll_on
        self.entry_mode |= LCD_ENTRYSHIFTINCREMENT;
        command(LCD_ENTRYMODESET | entry_mode);
      end

      def autoscroll_off
        self.entry_mode &= ~LCD_ENTRYSHIFTINCREMENT;
        command(LCD_ENTRYMODESET | entry_mode);
      end

      # Define custom characters as bitmaps.
      def create_char(location, bitmap)
        location &= 0x7
        command(LCD_SETCGRAMADDR | (location << 3))
        bitmap.each { |byte| write byte }
      end

      def command(byte)
        send(byte, board.low)
      end

      def write(byte)
        send(byte, board.high)
      end

      def send(byte, rs_level)
        # RS pin goes low to send commands, high to send data.
        rs.write(rs_level) unless rs.state == rs_level

        # Get the byte as a string of 0s and 1s, LSBFIRST.
        bits_from_byte = byte.to_s(2).rjust(8, "0").reverse

        # Write bits depending on connection.
        data_lines == 8 ? write8(bits_from_byte) : write4(bits_from_byte)
      end

      def write4(bits)
        if board.is_a?(Denko::Behaviors::BoardProxy)
          board.bit_set(d4.pin, bits[4].to_i)
          board.bit_set(d5.pin, bits[5].to_i)
          board.bit_set(d6.pin, bits[6].to_i)
          d7.write bits[7].to_i
          pulse_enable
          board.bit_set(d4.pin, bits[0].to_i)
          board.bit_set(d5.pin, bits[1].to_i)
          board.bit_set(d6.pin, bits[2].to_i)
          d7.write bits[3].to_i
          pulse_enable
        else
          d4.write bits[4].to_i
          d5.write bits[5].to_i
          d6.write bits[6].to_i
          d7.write bits[7].to_i
          pulse_enable
          d4.write bits[0].to_i
          d5.write bits[1].to_i
          d6.write bits[2].to_i
          d7.write bits[3].to_i
          pulse_enable
        end
      end

      def write8(bits)
        if board.is_a?(Denko::Behaviors::BoardProxy)
          board.bit_set(d0.pin, bits[0].to_i)
          board.bit_set(d1.pin, bits[1].to_i)
          board.bit_set(d2.pin, bits[2].to_i)
          board.bit_set(d3.pin, bits[3].to_i)
          board.bit_set(d4.pin, bits[4].to_i)
          board.bit_set(d5.pin, bits[5].to_i)
          board.bit_set(d6.pin, bits[6].to_i)
          d7.write bits[7].to_i
          pulse_enable
        else
          d0.write bits[0].to_i
          d1.write bits[1].to_i
          d2.write bits[2].to_i
          d3.write bits[3].to_i
          d4.write bits[4].to_i
          d5.write bits[5].to_i
          d6.write bits[6].to_i
          d7.write bits[7].to_i
          pulse_enable
        end
      end

      def pulse_enable
        enable.low
        micro_delay 1
        enable.high
        micro_delay 1
        enable.low
        micro_delay 100
      end
    end
  end
end
