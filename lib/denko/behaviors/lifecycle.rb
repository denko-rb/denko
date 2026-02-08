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
      CALLBACK_METHODS = [:before_initialize, :after_initialize]

      # Automatically add callback registration class methods to including classes
      def self.included(base); base.extend ClassMethods; end

      # @!parse extend ClassMethods
      module ClassMethods
        private

        # @!group Callback DSL
        # @!visibility public

        # Registers the given block as a callback to run before main body of {Component#initialize}.
        #
        # @yield callback to run
        # @return [Array<Proc>] all callbacks defined using `.before_initialize` for this class
        # @!method before_initialize

        # Registers the given block as a callback to run after main body of {Component#initialize}.
        #
        # @yield callback to run
        # @return [Array<Proc>] all callbacks defined using `.after_initialize` for this class
        # @!method after_initialize

        # @!endgroup

        CALLBACK_METHODS.each do |method_sym|
          civar_sym = "@#{method_sym}_cbs".to_sym
          define_method(method_sym) do |&block|
            if self.instance_variable_defined?(civar_sym)
              blocks = self.instance_variable_get(civar_sym)
            else
              blocks = []
            end
            blocks << block
            self.instance_variable_set(civar_sym, blocks)
          end
        end
      end

      private

      # @!group Callback Runners (Internal)
      # @!visibility public

      # Runs all before initialize callbacks in the component's hierarchy, in **bottom-up order**: those defined in descendents first, then ancestors
      #
      # @api private
      # @return [void]
      # @note called at the start of {Component#initialize}
      # @!method run_before_initialize_cbs

      # Runs all after initialize callbacks in the component's hierarchy, in **top-down order**: those defined in ancestors first, then descendents
      #
      # @api private
      # @return [void]
      # @note called at the end of {Component#initialize}
      # @!method run_after_initialize_cbs

      # @!endgroup

      CALLBACK_METHODS.each do |method_sym|
        civar_sym  = "@#{method_sym}_cbs".to_sym
        runner_sym = "run_#{method_sym}_cbs".to_sym

        define_method(runner_sym) do
          # Need to check civars in ancestors too.
          klasses = self.class.ancestors
          # If running "after" reverse hierarchy so they run top-down.
          klasses = klasses.reverse if method_sym.to_s.start_with? "after"

          blocks = []
          klasses.each do |klass|
            if klass.instance_variable_defined?(civar_sym)
              blocks << klass.instance_variable_get(civar_sym)
            end
          end
          blocks = blocks.flatten
          blocks.each { |b| instance_exec(&b) }
        end
      end
    end
  end
end
