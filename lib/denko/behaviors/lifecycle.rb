module Denko
  module Behaviors
    #
    # Provides callback hooks for hierarchical initialization in {Component} subclasses.
    #
    # @see Denko::Behaviors::Component#initialize
    #
    # @example Using Lifecycle callbacks
    #   class BaseSensor
    #     include Denko::Behaviors::Component
    #     include Denko::Behaviors::Lifecycle
    #
    #     before_initialize do
    #       raise ArgumentError, "address is required" unless params[:address]
    #     end
    #
    #     after_initialize do
    #       @some_default = 20
    #     end
    #   end
    #
    #   class SensorVariant < Base Sensor
    #     include Denko::Behaviors::Lifecycle
    #
    #     # Runs before callbacks defined in BaseSensor.
    #     before_initialize do
    #       params[:address] = 0x3C
    #     end
    #
    #     # Runs after callbacks defined in BaseSensor.
    #     after_initialize do
    #       @some_default = 40
    #     end
    #   end
    #
    module Lifecycle
      # @private
      CALLBACK_METHODS = %i[before_initialize after_initialize]

      # Defines callback methods in including classes.
      def self.included(base)
        base.extend ClassMethods
      end

      # @!parse extend ClassMethods
      module ClassMethods
        private
        # @!visibility public

        # Adds given block as callback to run before main body of {Component#initialize}.
        # These are hereditary, running in **bottom-up order:** callbacks from descendents first, then ancestors.
        #
        # @api private
        # @yield callback to run
        # @return [Array<Proc>] all callbacks defined using `.before_initialize` for this class
        # @!method before_initialize

        # Adds given block as callback to run after main body of {Component#initialize}.
        # These are hereditary, running in **top-down order:** callbacks from ancestors first, then descendents.
        #
        # @api private
        # @yield callback to run
        # @return [Array<Proc>] all callbacks defined using `.after_initialize` for this class
        # @!method after_initialize

        CALLBACK_METHODS.each do |method_sym|
          civar_sym = "@#{method_sym}_cbs".to_sym
          define_method(method_sym) do |&block|
            blocks = instance_variable_defined?(civar_sym) ? instance_variable_get(civar_sym) : []
            blocks << block
            instance_variable_set(civar_sym, blocks)
          end
        end
      end

      private

      # @private

      # Runner for callbacks added by #before_initialize.
      #
      # @api private
      # @return [void]
      # @note called at the start of {Component#initialize}
      # @!method run_before_initialize_cbs

      # Runner for callbacks added by #after_initialize.
      #
      # @api private
      # @return [void]
      # @note called at the end of {Component#initialize}
      # @!method run_after_initialize_cbs

      CALLBACK_METHODS.each do |method_sym|
        civar_sym  = "@#{method_sym}_cbs".to_sym
        runner_sym = "run_#{method_sym}_cbs".to_sym

        define_method(runner_sym) do
          # Need to check civars in ancestors too.
          klasses = self.class.ancestors
          # If running "after" reverse hierarchy so they run top-down.
          klasses = klasses.reverse if method_sym.to_s.start_with? 'after'

          blocks = []
          klasses.each do |klass|
            blocks << klass.instance_variable_get(civar_sym) if klass.instance_variable_defined?(civar_sym)
          end
          blocks = blocks.flatten
          blocks.each { |b| instance_exec(&b) }
        end
      end
    end
  end
end
