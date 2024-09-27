module Denko
  module Behaviors
    module OutputPin
      include Component
      include SinglePin
      include Lifecycle

      OUTPUT_MODES = [:output, :output_pwm, :output_dac, :output_open_drain, :output_open_source]

      before_initialize do
        params[:mode] ||= :output
        unless OUTPUT_MODES.include?(params[:mode])
          raise "invalid input mode: #{params[:mode]} given. Should be one of #{OUTPUT_MODES.inspect}"
        end
      end
    end
  end
end
