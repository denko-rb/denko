module Denko
  module Behaviors
    module BusController
      include Component
      include Subcomponents

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
