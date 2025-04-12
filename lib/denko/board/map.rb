require 'yaml'

module Denko
  class Board
    MAPS_FOLDER = File.join(Denko.root, "vendor/board-maps/yaml")

    attr_reader :map

    def substitute_zero_pins
      ["SDA", "SCL", "MOSI", "MISO", "SCK", "SS"].each do |name|
        symbol      = name.to_sym
        zero_symbol = (name + "0").to_sym
        @map[symbol] = @map[zero_symbol] if (@map[zero_symbol] && !@map[symbol])
      end
    end

    def load_map(board_name)
      if board_name
        map_path = File.join(MAPS_FOLDER, "#{board_name}.yml")
        @map = YAML.load_file(map_path)
        substitute_zero_pins
      else
        @map = nil
      end
    rescue
      raise StandardError, "error loading board map from file for board name: '#{board_name}'"
    end

    def convert_pin(pin)
      # Convert non numerical strings to symbols.
      pin = pin.to_sym if (pin.class == String) && !(pin.match (/\A\d+\.*\d*/))

      # Handle symbols.
      if (pin.class == Symbol)
        if map && map[pin]
          return map[pin]
        elsif map
          raise ArgumentError, "error in pin: #{pin.inspect}. Make sure that pin is defined for this board by calling Board#map"
        else
          raise ArgumentError, "error in pin: #{pin.inspect}. Given a Symbol, but board has no map. Try using GPIO integer instead"
        end
      end

      # Handle integers.
      return pin if pin.class == Integer

      # Try #to_i on anyting else. Will catch numerical strings.
      begin
        return pin.to_i
      rescue
        raise ArgumentError, "error in pin: #{pin.inspect}"
      end

      def pin_is_pwm?(pin)
        false
      end
    end
  end
end
