module Denko
  module Display
    class ST7302
      include Behaviors::Lifecycle
      include SPICommon

      # Commands
      SWRESET     = 0x01
      DISPOFF     = 0x28
      DISPON      = 0x29
      OSC_EN      = 0xC7
      BSTEN       = 0xD1
      SLPIN       = 0x10
      SLPOUT      = 0x11
      HPM         = 0x38
      LPM         = 0x39
      NVMLOADEN   = 0xEB
      NVMLOADCTRL = 0xD7
      GCTRL       = 0xC0
      SCTRL1      = 0xC1
      SCTRL2      = 0xC2
      VCOMCTRL    = 0xCB
      GATEUPDEQ   = 0xB4
      DUTYSET     = 0xB0
      DTFORM      = 0x3A
      SOCSET      = 0xB9
      PNLSET      = 0xB8
      MADCTL      = 0x36
      CASET       = 0x2A
      RASET       = 0x2B
      INVOFF      = 0x20
      INVON       = 0x21
      FRCTRL      = 0xB2
      RAMWR       = 0x2C

      # Each column in the controller's RAM is 12 pixels wide.
      # The hardware suppports column addresses 20..39 and
      # for a 122 pixel wide display, the first used column is 25.
      RAM_COLUMN_START = 25

      # Treat memory rows as columns, and columns as rows. Bytes will fall properly.
      COLUMNS = 250
      ROWS    = 122

      after_initialize do
        reset.high if reset
        dc.high
        sleep 0.1

        command [HPM]
        command [NVMLOADEN];    data [0x02]
        command [NVMLOADCTRL];  data [0x68]
        command [BSTEN];        data [0x01]
        command [GCTRL];        data [0x80]
        command [SCTRL1];       data [0x28, 0x28, 0x28, 0x28, 0x14, 0x00]
        command [SCTRL2];       data [0x00, 0x00, 0x00, 0x00]
        command [VCOMCTRL];     data [0x14]
        command [GATEUPDEQ];    data [0xE5, 0x77, 0xF1, 0xFF, 0xFF, 0x4F, 0xF1, 0xFF, 0xFF, 0x4F]
        command [SLPOUT]
        sleep 0.1

        command [OSC_EN];   data [0xA6, 0xE9]
        command [DUTYSET];  data [0x64]
        command [MADCTL];   data [0x20] # HW column auto-increments after last line. Important!
        command [DTFORM];   data [0x11]
        command [SOCSET];   data [0x23]
        command [PNLSET];   data [0x09]
        command [DISPON]
        command [SOCSET];   data [0xE3]
        sleep 0.1
        command [SOCSET];   data [0x23]
        sleep 0.1

        self.frame_rate = 8
      end

      def invert_on
        command [INVON]
      end

      def invert_off
        command [INVOFF]
      end

      VALID_FRAME_RATES = {
        # High power mode
        32    => [0x1, 0x0],
        16    => [0x0, 0x0],
        # Low power mode
        8     => [0x0, 0x5],
        4     => [0x0, 0x4],
        2     => [0x0, 0x3],
        1     => [0x0, 0x2],
        0.5   => [0x0, 0x1],
        0.25  => [0x0, 0x0]
      }
      def frame_rate=(fps)
        raise ArgumentError, "Invalid frame rate: #{fps} given" unless VALID_FRAME_RATES.keys.include? fps
        power_mode = (fps > 8) ? HPM : LPM
        command [power_mode]
        command [FRCTRL]
        data VALID_FRAME_RATES[fps]
      end

      #
      # This controller maps memory to pixels in a very unusual way, different to Canvas.
      # Each "chunk" it accepts is 3 bytes (A through C below), representing:
      # 2 pixels wide (2 columns in Canvas FB, or 1 "line" on the controller), by
      # 12 pixels tall (1.5 pages in Canvas FB or 1 "column" on the controller):
      #
      # A7 A6 -
      # A5 A4   |
      # A3 A2   |  In framebuffer space this maps to:
      # A1 A0   |- 2 complete bytes, sequential colummns, on same Canvas page,
      # B7 B6   |  but they have to be interleaved in controller RAM
      # B5 B4   |
      # B3 B2   |
      # B1 B0 -
      # C7 C6 -
      # C5 C4   |
      # C3 C2   |- Same as above, but 2 low nibbles from 2 sequential bytes
      # C1 C0 -
      #
      # For odd numbered "chunks", this is flipped. The corresponding high nibbles are first,
      # then 2 whole bytes. Note that bit order is reversed compared to Canvas...
      #
      # Also note we are mapping Canvas framebuffer pages to what the controller calls "columns",
      # and mapping framebuffer columns to what the controller calls "rows", essentially rotating it
      # by 90 degrees. This makes it easier to transform a Canvas framebuffer into device RAM.
      #
      # Finally, use these 2 packing methods to take either the lower or upper nibbles
      # from a pair of bytes, inteleave and reverse them to fit the format above.
      #
      def pack_lower4(left, right)
        result = 0
        (0..3).each do |index|
          result |= ((left >> index) & 0b1)  << (7 - (index*2))
          result |= ((right >> index) & 0b1) << (7 - (index*2 + 1))
        end
        result
      end

      def pack_upper4(left, right)
        result = 0
        (4..7).each do |index|
          result |= ((left >> index) & 0b1)  << (7 - ((index-4)*2))
          result |= ((right >> index) & 0b1) << (7 - ((index-4)*2 + 1))
        end
        result
      end

      def draw_partial(buffer, x_start, x_finish, p_start, p_finish, color=1)
        # Controller does 2 pixels for each memory line. Ensure start on even.
        x_start = (x_start / 2.0).floor * 2

        # Because of weird RAM layout, always start partials on a framebuffer page divisible by 3.
        # This corresponds to row divisible by 24, so a RAM column (12 px tall) divisible by 2.
        # Always write to RAM in pairs of pages. Avoids keeping track of separated nibbles from buffer.
        # Don't care to optimize this further.
        page = (p_start / 3.0).floor * 3

        # Each RAM column address is really 2 canvas columns.
        ram_x_start = x_start / 2
        ram_x_finish = (x_finish / 2.0).floor

        while (page <= p_finish) do
          upper_page = []
          lower_page = []

          x = x_start
          while (x <= x_finish) do
            # Take 6 bytes from the Canvas buffer, 2 columns across, 3 pages (24 rows) down.
            a1_index = (page * columns)     + x
            a2_index = ((page+1) * columns) + x
            a3_index = ((page+2) * columns) + x
            b1_index = (page * columns)     + x+1
            b2_index = ((page+1) * columns) + x+1
            b3_index = ((page+2) * columns) + x+1
            a1 = buffer[a1_index] || 0
            a2 = buffer[a2_index] || 0
            a3 = buffer[a3_index] || 0
            b1 = buffer[b1_index] || 0
            b2 = buffer[b2_index] || 0
            b3 = buffer[b3_index] || 0
            # Transform them to match the RAM format, and add to their respective temp pages.
            upper_page += [pack_lower4(a1, b1), pack_upper4(a1, b1), pack_lower4(a2, b2)]
            lower_page += [pack_upper4(a2, b2), pack_lower4(a3, b3), pack_upper4(a3, b3)]
            x += 2
          end

          # Transform from FB page index (8 px per page) to RAM column index (12 px per column).
          ram_page = ((page * 8) / 12) + RAM_COLUMN_START

          # Write two temp pages into 2 controller RAM columns.
          command [CASET]; data [ram_page, ram_page+1]
          command [RASET]; data [ram_x_start, ram_x_finish]
          command [RAMWR]
          upper_page.each_slice(transfer_limit) { |slice| data(slice) }
          lower_page.each_slice(transfer_limit) { |slice| data(slice) }

          # Advance 3 framebuffer pages since taking 24 rows each loop.
          page += 3
        end
      end
    end
  end
end
