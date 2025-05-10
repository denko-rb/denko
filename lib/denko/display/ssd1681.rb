module Denko
  module Display
    class SSD1681
      include Behaviors::Lifecycle
      include SPICommon
      #
      # On this display, each byte is 8 horizontal pixels, not vertical, like framebuffer. Swap
      # columns and rows to deal with this, then rotate framebuffer 90 degrees by default to compensate.
      #
      # RAM to pixel mapping doesn't match the framebuffer either, so invert both address ranges,
      # set them to decrement (not increment), and just send the frame bytes reversed.
      #
      # REMINDER: ROWS is always the count of pixels in the direction parallel to a single byte of
      #           8 framebuffer pixels being displayed. COLUMNS is the other direction.
      #
      COLUMNS = 200
      ROWS    = 200

      def x_start
        @x_start ||= (rows / 8) - 1
      end

      def x_finish
        @x_finish ||= 0
      end

      def y_start
        @y_start ||= columns - 1
      end

      def y_finish
        @y_finish ||= 0
      end

      # Typical Commands
      SW_RESET                = 0x12
      DRIVER_OUTPUT_CTL       = 0x01 # +3 data
      DATA_ENTRY_MODE_SET     = 0x11 # +1 data
      BORDER_WAVEFORM_CTL     = 0x3C # +1 data
      DISPLAY_UPDATE_CTL1     = 0x21 # +1 data
      TEMP_SENSOR_SELECT      = 0x18 # +1 data
      RAM_X_RANGE_SET         = 0x44 # +2 data. X address range to stay within.
      RAM_Y_RANGE_SET         = 0x45 # +4 data. Y address range to stay within.
      RAM_X_ADDR_SET          = 0x4E # +1 data. X start address
      RAM_Y_ADDR_SET          = 0x4F # +2 data. Y start address
      RAM_WRITE_BW            = 0x24 # write n pixel data bytes after
      RAM_WRITE_RED           = 0x26 # write n pixel data bytes after
      MASTER_ACTIVATION       = 0x20
      DISPLAY_UPDATE_CTL2     = 0x22 # +1 data
      DEEP_SLEEP              = 0x10 # +1 data
      BOOSTER_CTL             = 0x0C # +4 data

      #
      # Other commands taken from data sheet.
      # Not used yet. Maybe for enabling more features in future?
      #
      RAM_AUTO_INC_BW         = 0x46 # +1 data. This sets the auto-increment amount?
      RAM_AUTO_INC_RED        = 0x47 # +1 data. This sets the auto-increment amount?
      READ_RAM                = 0x27 # read n pixel data bytes after
      GATE_VOLTAGE_CTL        = 0x03 # +1 data
      SOURCE_VOLTAGE_CTL      = 0x04 # +3 data
      INITIAL_CODE_OTP        = 0x08 # ???
      INITIAL_CODE_REG_SET    = 0x08 # +3 data
      INITIAL_CODE_REG_GET    = 0x0A # Read 3 bytes back? Datasheet not clear.
      HV_READY_DETECTION      = 0x14 # +1 data
      VCI_DETECTION           = 0x15 # +1 data
      TEMP_SENSOR_REG_SET     = 0x1A # +2 data
      TEMP_SENSOR_REG_GET     = 0x1B # +2 data READ
      TEMP_SENSOR_CTL         = 0x1C # +3 data
      VCOM_SENSE              = 0x28
      VCOM_SENS_DURATION      = 0x29 # +1 data
      PROGRAM_VCOM_OTP        = 0x2A # +1 data
      VCOM_REG_CTL            = 0x2B # +2 data
      VCOM_REG_WRITE          = 0x2C # +1 data
      OTP_REG_GET             = 0x2D # +11 data READ
      USER_ID_GET             = 0x2E # +10 data READ
      STATUS_BIT_GET          = 0x2F # +1 data READ
      PROGRAM_WS_OTP          = 0x30
      LOAD_WS_OTP             = 0x31
      WRITE_LUT_REGISTER      = 0x32 # +153 data
      CRC_CALCULATION         = 0x34
      CRC_STATUS_GET          = 0x35 # +2 data READ
      PROGRAM_OTP_SELECTION   = 0x36
      DISPLAY_OPTION_REG_SET  = 0x37 # +10 data
      USER_ID_REG_SET         = 0x38 # +10 data
      OTP_PROGRAM_MODE        = 0x39 # +1 data
      END_OPTION              = 0x3F # +1 data
      READ_RAM_OPTION         = 0x41 # +1 data
      NOP                     = 0x7F

      def set_driver_output_control(gate_lines=rows)
        mux = gate_lines - 1
        # First data byte is lowest 8 bits of MUX value.
        # Second byte is 9th bit.
        # Third byte is all 0s for default. Not implemented yet:
        #   Bit 2: toggles gate scan interleave order
        #   Bit 1: enables gate scan interleaving
        #   Bit 0: flips gate scan direction, mirroring display in 1 axis (must be 1 for us)
        command [DRIVER_OUTPUT_CTL]
        data    [mux & 0xFF, (mux >> 8) & 0b1, 0b001]
      end

      def set_data_entry_mode
        # Bit 2 = 1 : update Y address first (after each byte), then update X at Y limit. (0 would swap X and Y)
        # Bit 1 = 0 : decrement Y (1 would increment)
        # Bit 0 = 0 : decrement Y (1 would increment)
        command [DATA_ENTRY_MODE_SET]
        data    [0b100]
      end

      def set_range_x(start=x_start, finish=x_finish)
        command [RAM_X_RANGE_SET]
        data    [start, finish]
      end

      def set_range_y(start=y_start, finish=y_finish)
        command [RAM_Y_RANGE_SET]
        data    [start & 0xFF, (start >> 8) & 0b1, finish & 0xFF, (finish >> 8) & 0b1]
      end

      def set_address_x(addr=x_start)
        command [RAM_X_ADDR_SET]
        data    [addr]
      end

      def set_address_y(addr=y_start)
        command [RAM_Y_ADDR_SET]
        data    [addr & 0xFF, (addr >> 8) & 0b1]
      end

      def set_panel_border
        # Default to GS Transition: Follow LUT and LUT1, and VBD fix level: VSS.
        command [BORDER_WAVEFORM_CTL]
        data    [0b00_00_00_01]
      end

      def set_temperature_sensor
        # Use internal temperature sensor
        command [TEMP_SENSOR_SELECT]
        data [0x80]
      end

      def set_display_update_control
        # Need to invert black. Ignore red for now.
        command [DISPLAY_UPDATE_CTL1]
        data    [0b0100_1000]
      end

      def set_display_update_sequence(value=0x80)
        # 0x80 enables clock signal without loading pixels from RAM
        # 0xF7 refreshes all pixels from RAM
        command [DISPLAY_UPDATE_CTL2]
        data    [value]
      end

      def booster_soft_start
        command [BOOSTER_CTL]
        data [
          0b1000_1011, # phase 1
          0b1001_1100, # phase 2
          0b1001_0110, # phase 3
          0b0000_0000, # duration
        ]
      end

      def master_activate
        command [MASTER_ACTIVATION]
      end

      def deep_sleep(sleep_mode=0b11)
        # 0b00 = Normal Mode
        # 0b01 = Deep Sleep Mode 1
        # 0b11 = Deep Sleep Mode 2
        command [DEEP_SLEEP]
        data    [sleep_mode]
      end

      def initialize_pins(options={})
        super(options)
        proxy_pin :busy, DigitalIO::Input, board: bus.board
        busy.stop
      end

      def busy_wait
        # Could use listener here, but #read is more compatible.
        sleep 0.005 while busy.read == 1
      end

      after_initialize do
        # Reset Sequence
        sleep 0.010
        if reset
          reset.low
          sleep 0.1
          reset.high
        end
        command [SW_RESET]
        sleep 0.020

        set_driver_output_control
        set_data_entry_mode
        set_temperature_sensor
        set_panel_border

        set_display_update_control
        set_display_update_sequence
        master_activate
        busy_wait

        # Rotate 90 by default, since treating columns as rows and vice versa.
        canvas.rotate(90)
      end

      def draw(x_min=0, x_max=0, y_min=0, y_max=0)
        draw_partial(canvas.framebuffer, x_min, x_max, y_min, y_max)
      end

      def draw_partial(buffer, x_min=0, x_max=0, y_min=0, y_max=0)
        # Args in canvas-space. Accept to avoid breakage, but write entire buffer to RAM anyway.
        # E-paper wont't refresh fast enough to justify complexity of partial udpates.
        #
        set_range_x
        set_range_y
        set_address_x
        set_address_y

        command [RAM_WRITE_BW]
        buffer.reverse.each_slice(transfer_limit) { |slice| data(slice) }

        booster_soft_start
        set_display_update_sequence(0xF7)
        master_activate
        busy_wait
      end
    end
  end
end
