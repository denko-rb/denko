module Denko
  module Display
    class ST7565
      include SPI::Peripheral::MultiPin
      include Behaviors::Lifecycle

      def initialize_pins(options={})
        super(options)
        proxy_pin :dc,    DigitalIO::Output, board: bus.board
        proxy_pin :reset, DigitalIO::Output, board: bus.board
      end

      def command(bytes)
        dc.low
        spi_write(bytes)
      end

      def data(bytes)
        dc.high
        spi_write(bytes)
      end

      def columns
        @columns ||= params[:columns] || 128
      end

      def rows
        @rows ||= params[:rows] || 64
      end

      def canvas
        @canvas ||= Canvas.new(columns, rows)
      end

      # Overall commands
      RESET                 = 0b11100010
      DISPLAY_ON            = 0b10101111
      DISPLAY_OFF           = 0b10101110
      ALL_POINTS_OFF        = 0b10100100
      ALL_POINTS_ON         = 0b10100100
      STATIC_INDICATOR_OFF  = 0b10101100
      STATIC_INDICATOR_ON   = 0b10101101

      def standby
        command [DISPLAY_OFF, ALL_POINTS_ON]
      end

      def slp
        command [STATIC_INDICATOR_OFF, 0b00, DISPLAY_OFF, ALL_POINTS_ON]
      end

      def wake
        # Note static indicator stays disabled. Not sure how to use it.
        command [ALL_POINTS_OFF, DISPLAY_ON, STATIC_INDICATOR_OFF, 0b00]
      end

      # Overall votage commands
      POWER_CONTROL         = 0b00101000
      LCD_BIAS_1_7          = 0b10100011
      VOLUME                = 0b10000001
      VALID_VOLUMES         = (0..63).to_a
      #
      # Control voltage regulator circuit. Values 0-7 are OR'ed into last 3 bits.
      # 5 seems to work best for non-inverted mode, and 6 for inverted.
      RESISTOR_RATIO        = 0b00100000
      VALID_RESISTOR_RATIOS = (0..7).to_a

      def resistor_ratio=(ratio)
        raise ArgumentError, "invalid resistor ratio #{ratio}" unless VALID_RESISTOR_RATIOS.include? ratio
        command [RESISTOR_RATIO | ratio]
      end

      def volume=(value)
        raise ArgumentError, "invalid volume #{value}" unless VALID_VOLUMES.include? value
        command [VOLUME, value]
      end

      #
      # Addressing and writing to display RAM.
      # Always in write mode. Called Read-Modify-Write and END in datasheet.
      RMW_WRITE = 0b11100000
      RMW_END   = 0b11101110
      #
      # Set page and column to start on before writing data.
      # Page and column nibbles are OR'ed into lower 4 bits.
      PASET       = 0b10110000
      CASET_UPPER = 0b00010000
      CASET_LOWER = 0b00000000
      #
      # Control X and Y mirroring, so the display can be reflected
      # in either axis, or rotated 180 degrees, in hardware.
      #
      # How RAM columns map to pixels. Called ADC in datasheet.
      COL_NORMAL  = 0b10100000
      COL_REVERSE = 0b10100001
      # How RAM pages map to pixels. Called Common Output Mode in datasheet.
      PAGE_NORMAL  = 0b11000000
      PAGE_REVERSE = 0b11001000
      # RAM has 132 columns. Need to start at index 4 when columns get reversed.
      COL_REVERSE_COL_START = 4

      def x_ram_offset
        @x_ram_offset ||= 0
      end

      def reflect_x
        @reflected_x ||= false
        @reflected_x ? command([COL_NORMAL]) : command([COL_REVERSE])
        @reflected_x = !@reflected_x
        @x_ram_offset = @reflected_x ? COL_REVERSE_COL_START : 0
      end

      def reflect_y
        @reflected_y ||= false
        @reflected_y ? command([PAGE_NORMAL]) : command([PAGE_REVERSE])
        @reflected_y = !@reflected_y
      end

      def rotate
        reflect_x
        reflect_y
      end

      # Control display inversion.
      # White on black is OFF. Black on white ON.
      INVERT_OFF = 0b10100110
      INVERT_ON  = 0b10100111

      def invert
        @inverted ||= false
        if @inverted
          command [INVERT_OFF]
          self.resistor_ratio = 5
        else
          command [INVERT_ON]
          self.resistor_ratio = 6
        end
        @inverted = !@inverted
      end

      after_initialize do
        # Reset sequence.
        reset.low
        sleep 0.001
        reset.high
        command [RESET]

        # Enable all power circuits:
        # bit0 = voltage follower
        # bit1 = voltage regulator
        # bit2 = voltage booster
        command [POWER_CONTROL | 0b111]
        sleep 0.010

        # Set LCD voltage bias ratio
        command [LCD_BIAS_1_7]

        # Non-inverted display by default. Set resistor ratio and volume.
        self.resistor_ratio = 5
        self.volume = 16

        # Columns need to be reversed by default.
        reflect_x
        rotate if params[:rotated]

        wake
      end

      def draw(x_min=0, x_max=(columns-1), y_min=0, y_max=(rows-1))
        # Convert y-coords to page coords.
        p_min = y_min / 8
        p_max = y_max / 8

        # If drawing the whole frame (default), bypass temp buffer to save time.
        if (x_min == 0) && (x_max == columns-1) && (p_min == 0) && (p_max == rows/8)
          draw_partial(canvas.framebuffer, x_min, x_max, p_min, p_max)

        # Copy bytes for the given rectangle into a temp buffer.
        else
          temp_buffer = []
          (p_min..p_max).each do |page|
            src_start = (columns * page) + x_min
            src_end   = (columns * page) + x_max
            temp_buffer += canvas.framebuffer[src_start..src_end]
          end

          # And draw them.
          draw_partial(temp_buffer, x_min, x_max, p_min, p_max)
        end
      end

      def draw_partial(buffer, x_min, x_max, p_min, p_max)
        x = x_min + x_ram_offset
        x_lower4 = (x & 0b00001111)
        x_upper4 = (x & 0b11110000) >> 4

        (p_min..p_max).each do |page|
          command [RMW_WRITE]
          # Set start page and column.
          command [PASET | page, CASET_LOWER | x_lower4, CASET_UPPER | x_upper4]

          # Get needed bytes for this page only.
          src_start = (@columns * page) + x_min
          src_end   = (@columns * page) + x_max
          buffer    = canvas.framebuffer[src_start..src_end]

          # Send all bytes at once if within limit, or split into chunks.
          if buffer.length < (bus.board.i2c_limit - 1)
            data(buffer)
          else
            buffer.each_slice(bus.board.i2c_limit - 1) { |slice| data(slice) }
          end

          command [RMW_END]
        end
      end
    end
  end
end
