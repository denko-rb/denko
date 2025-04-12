module Denko
  module Display
    class SH1107 < SH1106
      # SH1107 RAM has 128 columns, unlike 132 on SH1106. Don't offset by 2.
      def ram_x_offset
        0
      end

      # Default to 128x128 resolution
      include Behaviors::Lifecycle

      before_initialize do
        params[:columns] ||= 128
        params[:rows]    ||= 128
      end
    end
  end
end
