module Denko
  module Display
    class PCD8544
      include Behaviors::Lifecycle
      include SPICommon

      COLUMNS = 84
      ROWS    = 48

      FUNCTION_SET = 0b00100000
      # OR these options into lowest 3 bits:
      POWER_UP      = 0b000
      POWER_DOWN    = 0b100
      H_ADDRESSING  = 0b00
      V_ADDRESSING  = 0b10
      BASIC_INS_SET = 0b0
      EXT_INS_SET   = 0b1

      #
      # Basic Instruciton Set (H = 0)
      #
      DISPLAY_CONTROL_SET = 0b00001000
      # OR these options into lowest 3 bits:
      DISPLAY_BLANK    = 0b000
      DISPLAY_NORMAL   = 0b100
      DISPLAY_ALL_SEGS = 0b001
      DISPLAY_INVERT   = 0b101

      RAM_Y_SET = 0b01000000 # OR Y value into lowest 3 bits
      RAM_X_SET = 0b10000000 # OR X value into lowest 7 bits

      #
      # Extended Instruciton Set (H = 1)
      #
      TEMP_COEFF_SET = 0b00000100 # OR temperature coeff. into lowest 2 bits
      BIAS_SET       = 0b00010000 # OR bias system values into lowest 3 bits
      VOP_SET        = 0b10000000 # OR VOP values into lowest 7 bits

      def power_up
        @function_state = (function_state & 0b11111011) | POWER_UP
        command [function_state]
      end

      def power_down
        @function_state = (function_state & 0b11111011) | POWER_DOWN
        command [function_state]
      end

      def basic_instruction_mode
        @function_state = (function_state & 0b11111110) | BASIC_INS_SET
        command [function_state]
      end

      def extended_instruction_mode
        @function_state = (function_state & 0b11111110) | EXT_INS_SET
        command [function_state]
      end

      def function_state
        @function_state ||= FUNCTION_SET
      end

      VALID_VOPS = (0..127).to_a

      def vop=(value)
        raise ArgumentError, "invalid Vop: #{value}" unless VALID_VOPS.include?(value)
        extended_instruction_mode
        command [VOP_SET | value]
        basic_instruction_mode
        @vop = value
      end

      VALID_BIASES = (0..7).to_a

      def bias=(value)
        raise ArgumentError, "invalid bias: #{value}" unless VALID_BIASES.include?(value)
        extended_instruction_mode
        command [BIAS_SET | value]
        basic_instruction_mode
        @bias = value
      end

      VALID_TCOEFFS = (0..3).to_a

      def temperature_coefficient=(value)
        raise ArgumentError, "invalid temperature coefficient: #{value}" unless VALID_TCOEFFS.include?(value)
        extended_instruction_mode
        command [TEMP_COEFF_SET | value]
        basic_instruction_mode
        @temperature_coefficient = value
      end

      def vop
        @vop ||= 0
      end

      def bias
        @bias ||= 0
      end

      def temperature_coefficient
        @temperature_coefficient ||= 0
      end

      def set_display_control(value)
        command [DISPLAY_CONTROL_SET | value]
      end

      def blank
        set_display_control(DISPLAY_BLANK)
      end

      def all_segments_on
        set_display_control(DISPLAY_ALL_SEGS)
      end

      def invert
        @inverted = !@inverted
        value = @inverted ? DISPLAY_INVERT : DISPLAY_NORMAL
        set_display_control(value)
      end

      after_initialize do
        # Reset sequence.
        reset.low if reset
        sleep 0.001
        reset.high if reset

        self.vop = 56
        self.bias = 4
        set_display_control(DISPLAY_NORMAL)
        self.temperature_coefficient = 0
      end

      def draw_partial(buffer, x_start, x_finish, p_start, p_finish, color=1)
        # Always use horizontal addressing mode.
        basic_instruction_mode

        (p_start..p_finish).each do |page|
          # Set start page and column.
          command [RAM_X_SET | x_start, RAM_Y_SET | page]

          # Get needed bytes for this page only.
          src_start       = (columns * page) + x_start
          src_end         = (columns * page) + x_finish
          partial_buffer  = []
          (0...length).each { |i| partial_buffer[i] = buffer[src_start+i].ord }

          # Send in chunks up to maximum transfer size.
          partial_buffer.each_slice(transfer_limit) { |slice| data(slice) }
        end
      end
    end
  end
end
