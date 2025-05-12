module Denko
  module Display
    class IL0373
      include SPIEPaperCommon
      include Behaviors::Lifecycle

      COLUMNS = 212
      ROWS    = 104

      # Subset of used commands from datasheet:
      PANEL_SETTING           = 0x00
      POWER_SETTING           = 0x01
      POWER_OFF               = 0x02
      POWER_OFF_SEQUENCE      = 0x03
      POWER_ON                = 0x04
      POWER_ON_MEASURE        = 0x05
      BOOSTER_SOFT_START      = 0x06
      DEEP_SLEEP              = 0x07
      DATA_START_1            = 0x10
      DATA_STOP               = 0x11
      DISPLAY_REFRESH         = 0x12
      DATA_START_2            = 0x13
      VCOM_DATA_SETTING       = 0x50
      RESOLUTION_SETTING      = 0x61
      PARTIAL_WINDOW          = 0x90
      PARTIAL_IN              = 0x91
      PARTIAL_OUT             = 0x92

      def set_power_setting
        # Defaults from datasheet.
        command [POWER_SETTING]
        data    [0x03, 0x00, 0x26, 0x26, 0x03]
      end

      def set_panel_setting
        # NOT DEFAULTS
        # From datasheet:
        #   Bits 7..6: Enable all source and gate channels
        #       Bit 5: 0 = LUT from OTP
        #       Bit 4: 0 = B/W/R mode, 1 = B/W mode
        #       Bit 3: 0 = Gate scan decrements (1 increments)
        #       Bit 2: 0 = Source scan decrements (1 increments)
        #       Bit 1: 1 = Enable booster
        #       Bit 0: 1 = Soft reset
        value  = 0b0000_0011

        # Handle colors
        value |= (1 << 4) if colors == 2

        # Handle screen size
        source_gate_bits = 0b11
        source_gate_bits = 0b10 if (rows <= 128)
        source_gate_bits = 0b01 if (rows <= 96) && (columns <= 252)
        source_gate_bits = 0b00 if (rows <= 96) && (columns <= 230)
        value |= source_gate_bits

        # Handle hardware reflection/rotation
        value |= (1 << 2) if @reflect_y
        value |= (1 << 3) if @reflect_x

        command [PANEL_SETTING]
        data    [value]
      end

      def reflect_x
        @reflect_x = !@reflect_x
      end

      def reflect_y
        @reflect_y = !@reflect_y
      end

      def rotate
        @reflect_x = !@reflect_x
        @reflect_y = !@reflect_y
      end

      def set_vcom_data_setting
        # Default value from data sheet.
        value = 0b0000_0111

        # Datsheet may be wrong here. Bit 5 set seems to always invert DATA2, so Bit 4 does DATA1?
        #   In B/W mode:   set bit 5 to avoid black channel inversion relative to Canvas.
        #   In B/W/R mode: set bit 4 to avoid black channel inversion relative to Canvas.
        if (colors == 2)
          value |= (1 << 4) unless @invert_black
        else
          value |= (1 << 5) unless @invert_black
        end

        command [VCOM_DATA_SETTING]
        data    [value]
      end

      def invert_black
        @invert_black = !@invert_black
      end

      def set_resolution
        command [RESOLUTION_SETTING]
        data [
          p_max+1 << 3,
          (columns >> 8) & 0b1,
          columns & 0xFF
        ]
      end

      def booster_soft_start
        # Defaults from datasheet.
        command [BOOSTER_SOFT_START]
        data    [0x17, 0x17, 0x17]
      end

      def power_on
        command [POWER_ON]
        busy_wait
      end

      def wake
        hw_reset
        set_power_setting
        set_panel_setting
        set_vcom_data_setting
        set_resolution
        booster_soft_start
        power_on
      end

      def deep_sleep
        # Default from datasheet.
        command [DEEP_SLEEP]
        data    [0xA5]
      end

      # Treat what the datasheet calls x as vertical (y, page), and vertical as horizontal (x).
      def set_window(x_start=x_min, x_finish=x_max, p_start=p_min, p_finish=p_max)
        command [PARTIAL_WINDOW]
        data [
          p_start  << 3,
          p_finish << 3,
          (x_start >> 8) & 0b1,
          x_start & 0xFF,
          (x_finish >> 8) & 0b1,
          x_finish & 0xFF,
          0b0
        ]
        command [PARTIAL_IN]
      end

      def draw(*args, **kwargs)
        wake
        super(*args, **kwargs)
      end

      def draw_partial(buffer, x_start, x_finish, p_start, p_finish, color=1)
        set_window(x_start, x_finish, p_start, p_finish)

        if (colors == 2)
          # In B/W/Red mode, red goes in DATA2, black in DATA1
          (color == 2) ? command[DATA_START_2] : command[DATA_START_1]
        else
          # In B/W mode, always write to DATA2
          command [DATA_START_2]
        end

        # Can't control address increment to go horizontally, always vertical.
        # So get partial from the full buffer and reorder the bytes.
        transformed_buffer = []
        (x_start..x_finish).each do |x|
          (p_start..p_finish).to_a.reverse.each do |page|
            index = (page * columns) + x
            transformed_buffer << buffer[index]
          end
        end
        transformed_buffer.each_slice(transfer_limit) { |slice| data(slice) }

        command [DATA_STOP]
      end

      def refresh
        command [DISPLAY_REFRESH]
        busy_wait
      end
    end
  end
end
