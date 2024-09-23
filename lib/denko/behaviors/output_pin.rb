module Denko
  module Behaviors
    module OutputPin
      include Component
      include SinglePin

      OUTPUT_MODES = [:output, :output_pwm, :output_dac, :output_open_drain, :output_open_source]

      protected

      def initialize_pins(options={})
        super(options)

        # Allow output type to be set with :mode, else default to :output.
        if options[:mode]
          initial_mode = options[:mode]
          unless OUTPUT_MODES.include?(initial_mode)
            raise "invalid input mode: #{initial_mode} given. Should be one of #{OUTPUT_MODES.inspect}"
          end
        else
          initial_mode = :output
        end

        self.mode = initial_mode
      end
    end
  end
end
