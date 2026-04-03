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
        def before_initialize(&block)
          @before_initialize_cbs ||= []
          @before_initialize_cbs << block
        end

        # Adds given block as callback to run after main body of {Component#initialize}.
        # These are hereditary, running in **top-down order:** callbacks from ancestors first, then descendents.
        #
        # @api private
        # @yield callback to run
        # @return [Array<Proc>] all callbacks defined using `.after_initialize` for this class
        # @!method after_initialize
        def after_initialize(&block)
          @after_initialize_cbs ||= []
          @after_initialize_cbs << block
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
      def run_before_initialize_cbs
        # Returns hierarchy in bottom-up order, correct for before callbacks.
        klasses = self.class.ancestors
        blocks = []
        klasses.each do |klass|
          if klass.instance_variable_defined?(:@before_initialize_cbs)
            blocks << klass.instance_variable_get(:@before_initialize_cbs)
          end
        end
        blocks.flatten.each { |b| instance_exec(&b) }
      end

      # Runner for callbacks added by #after_initialize.
      #
      # @api private
      # @return [void]
      # @note called at the end of {Component#initialize}
      # @!method run_after_initialize_cbs
      def run_after_initialize_cbs
        # Reverse hierarchy so after callbacks are run top-down.
        klasses = self.class.ancestors.reverse
        blocks = []
        klasses.each do |klass|
          if klass.instance_variable_defined?(:@after_initialize_cbs)
            blocks << klass.instance_variable_get(:@after_initialize_cbs)
          end
        end
        blocks.flatten.each { |b| instance_exec(&b) }
      end
    end
  end
end
