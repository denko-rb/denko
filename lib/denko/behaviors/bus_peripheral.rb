module Denko
  module Behaviors
    module BusPeripheral
      include Component

      alias  :bus :board

      before_initialize do
        params[:board] ||= params[:bus]
      end

      def atomically(&block)
        bus.mutex.synchronize do
          block.call
        end
      end
    end
  end
end
