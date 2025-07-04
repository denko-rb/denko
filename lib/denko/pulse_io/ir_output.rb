module Denko
  module PulseIO
    class IROutput
      include Behaviors::SinglePin
      include Behaviors::Lifecycle

      def write(pulses=[], frequency: 38)
        if pulses.length > 255 || pulses.length < 1
          raise ArgumentError, 'wrong number of IR pulses (expected 1 to 255)'
        end

        pulses.each_with_index do |pulse, index|
          raise ArgumentError, 'non Numeric data in IR signal' unless pulse.is_a? Numeric
          pulses[index] = pulse.round unless pulse.is_a? Integer
          raise ArgumentError, 'pulse too long (max 65535 ms)' if pulse > 65535
        end

        board.infrared_emit(pin, frequency, pulses)
      end
    end
  end
end
