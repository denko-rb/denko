module Denko
  module Display
    module MonoOLED
      include Behaviors::BusPeripheral
      include Behaviors::Lifecycle

      # I2C Defaults
        I2C_ADDRESS   = 0x3C
        I2C_FREQUENCY = 400_000

      # Fundamental Commands
        # Single byte (no need to OR with anything)
        PIXELS_FROM_RAM = 0xA4
        PIXELS_ALL_ON   = 0xA5
        INVERT_OFF      = 0xA6
        INVERT_ON       = 0xA7
        DISPLAY_OFF     = 0xAE
        DISPLAY_ON      = 0xAF

        # Double byte (following byte sets value)
        CONTRAST        = 0x81
          # Values: 0x00 to 0xFF. Default is 0x7F

      # Scrolling commands ignored.

      # Address Setting Commands
        # Single byte. OR with value. These are for page addressing mode only.
        COLUMN_START_LOWER = 0x00 # lower 4 bytes of column
        COLUMN_START_UPPER = 0x10 # upper 4 bytes of column
        PAGE_START         = 0xB0 # page 0-7

        # Double byte. Following byte sets value.
        ADDRESSING_MODE  = 0x20
          # Values:
          #   0x00 = horizontal (Pages auto-increment. Used for SSD1306)
          #   0x01 = vertical
          #   0x02 = page       (Default. Page and column must be set each time. Needed on SH1106, SH1107)
        ADDRESSING_MODE_DEFAULT = 0x00

        # Triple byte. Following 2 bytes sets value. For H/V addressing modes only.
        COLUMN_ADDRESS_RANGE = 0x21
        PAGE_ADDRESS_RANGE   = 0x22
          # For both: first value = min column/row, second value = max column/row

      # Hardware Configuration Commands
        # Single byte. OR with value.
        START_LINE      = 0x40  # Value: lowest 6 bits set RAM start line (default 0b000000)
        SEGMENT_REMAP   = 0xA0  # Value: 0x00 = default, 0x01 = column draw order reversed (horizontal reflection)
        COM_DIRECTION   = 0xC0  # Value: 0x00 = default, 0x08 = row draw order reversed (vertical reflection)

        # Double-byte commands. Following byte sets value.
        CHARGE_PUMP = 0x8D  # Value: 0x10 = disable/external, 0x14 = enable/internal
        MULTIPLEX_RATIO = 0xA8  # Value: rows of display - 1
        DISPLAY_OFFSET  = 0xD3  # Value: lowest 5 bits. Vertically shifts COM by that amount.
        COM_PIN_CONFIG  = 0xDA
          # 0x02 = sequential, left and right not swapped
          # 0x12 = alternative, left and right not swapped (default)
          # 0x22 = sequential, left and right sawpped
          # 0x32 = alternative, left and right swapped

      # Timing & Driving Commands
        # Double-byte commands. Following byte sets value.
        CLOCK               = 0xD5  # Lowest 4 bits = divider. Upper 4 bits = oscillator frequency.
        PRECHARGE_PERIOD    = 0xD9  # Lowest 4 bits = phase 1. Upper 4 bits = phase 2. 0xF1 for internal charge pump. 0x22 for external.
        VCOM_DESELECT_LEVEL = 0xDB  # 0x00 = 0.65 x Vcc, 0x20 = x 0.77 * Vcc (default), 0x30 = 0.83 x Vcc

      # Valid widths and heights for displays
      WIDTHS  = [64,96,128]
      HEIGHTS = [16,32,48,64,128]

      # Default to a 128x64 display.
      COLUMNS = 128
      ROWS    = 64

      def rotated
        return @rotated unless @rotated.nil?
        @rotated = params[:rotated]
        @rotated = params[:rotate] if @rotated.nil?
        @rotated = false if @rotated.nil?
        @rotated
      end

      # Decide whether this instnace is I2C or SPI.
      before_initialize do
        bus = params[:bus] || params[:board]

        if bus.class.ancestors.include?(Denko::SPI::Bus) || bus.class.ancestors.include?(Denko::SPI::BitBang)
          mutate_spi
        elsif bus.class.ancestors.include?(Denko::I2C::Bus) || bus.class.ancestors.include?(Denko::I2C::BitBang)
          mutate_i2c
        else
          raise ArgumentError, "#{self.class} must be connected to either an I2C or SPI bus"
        end
      end

      after_initialize do
        # Validate known sizes.
        raise ArgumentError, "error in #{self.class} width: #{columns}. Must be in: #{WIDTHS.inspect}" unless WIDTHS.include?(columns)
        raise ArgumentError, "error in #{self.class} height: #{rows}. Must be in: #{HEIGHTS.inspect}" unless HEIGHTS.include?(rows)

        # Everything except 96x16 size uses clock 0x80.
        clock = 0x80
        clock = 0x60 if (columns == 96 && rows == 16)

        # 128x32 and 96x16 sizes use com pin config 0x02
        com_pin_config = 0x12
        com_pin_config = 0x02 if (columns == 96 && rows == 16) || (columns == 128 && rows == 32)

        # Reflecting horizontally and vertically to effectively rotate 180 degrees.
        seg_remap     = rotated ? 0x01 : 0x00
        com_direction = rotated ? 0x08 : 0x00

        # Startup sequence (SPI doesn't work properly if this isn't sent twice.)
        2.times do
        command [
          MULTIPLEX_RATIO,        rows - 1,
          DISPLAY_OFFSET,         0x00,
          START_LINE            | 0x00,
          SEGMENT_REMAP         | seg_remap,
          COM_DIRECTION         | com_direction,
          COM_PIN_CONFIG,         com_pin_config,
          PIXELS_FROM_RAM,
          INVERT_OFF,
          CLOCK,                  clock,
          VCOM_DESELECT_LEVEL,    0x20,
          PRECHARGE_PERIOD,       0xF1,           # Charge period for internal charge pump
          CHARGE_PUMP,            0x14,           # Internal charge pump
          ADDRESSING_MODE,        self.class::ADDRESSING_MODE_DEFAULT,
          DISPLAY_ON
        ]
        end

        draw
      end

      def off
        command [DISPLAY_OFF]
      end

      def on
        command [DISPLAY_ON]
      end

      def contrast=(value)
        raise ArgumentError, "contrast must be in range 0..255" if (value < 0 || value > 255)
        command [CONTRAST, value]
      end

      def draw_partial(buffer, x_min, x_max, p_min, p_max)
        raise NotImplementedError, "#draw_partial must be implemented for each class including MonoOLED"
      end

      def mutate_i2c
        singleton_class.class_eval do
          include I2C::Peripheral
          include PixelCommon

          # Commands are I2C messages prefixed with 0x00.
          def command(bytes)
            i2c_write([0x00] + bytes)
          end

          # Data are I2C messages prefixed with 0x40.
          def data(bytes)
            i2c_write([0x40] + bytes)
          end

          # Data prefix always takes one byte, so subtract that.
          def transfer_limit
            @transfer_limit ||= bus.board.i2c_limit - 1
          end
        end
      end

      def mutate_spi
        singleton_class.class_eval do
          include SPICommon
        end
      end
    end
  end
end
