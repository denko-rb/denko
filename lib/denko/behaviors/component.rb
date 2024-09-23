module Denko
  module Behaviors
    module Component
      include State
      attr_reader :board, :params

      #
      # Callback hook DSL for setup work in including classes.
      # include(Component) in final classes to get callbacks methods.
      #
      def self.included(base); base.extend ClassMethods; end
      #
      CALLBACK_METHODS = [:before_initialize, :after_initialize]

      # Callback methods themselves.
      module ClassMethods
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

      # Instance method runners.
      CALLBACK_METHODS.each do |method_sym|
        civar_sym  = "@#{method_sym}_cbs".to_sym
        runner_sym = "run_#{method_sym}_cbs".to_sym

        define_method(runner_sym) do
          # Need to check civars in ancestors too.
          klasses = self.class.ancestors
          # If running "after" reverse hierarchy so they run top-down.
          klasses = klasses.reverse if method_sym.match? /after/

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

      def initialize(options={})
        @params = options
        run_before_initialize_cbs

        initialize_board
        convert_pins(params)
        initialize_pins(params)
        register

        run_after_initialize_cbs
      end

      def micro_delay(duration)
        board.micro_delay(duration)
      end

      protected

      def initialize_board
        raise ArgumentError, 'a board is required for a component' unless params[:board]
        @board = params[:board]
      end

      def register
        board.add_component(self)
      end

      def unregister
        board.remove_component(self)
      end

      # Behaviors::Component only requires a board.
      # Include modules from Setup or override this to use pins.
      #
      def before_initialize(options={}); end
      def convert_pins(options={});      end
      def initialize_pins(options={});   end
      alias :initialize_pin :initialize_pins

      # Override in components. Call super when inheriting or mixing in.
      def after_initialize(options={}); end
    end
  end
end
