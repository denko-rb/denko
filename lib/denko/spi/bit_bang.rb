module Denko
  module SPI
    class BitBang
      include Behaviors::MultiPin
      include Behaviors::BusController
      include Behaviors::Reader
      include Behaviors::Lifecycle

      before_initialize do
        init_pins = params[:pins]
        # Allow pin aliases.
        param_pins[:input]  = param_pins[:input]  || param_pins[:poci] || param_pins[:miso]
        param_pins[:output] = param_pins[:output] || param_pins[:pico] || param_pins[:mosi]
        param_pins[:clock]  = param_pins[:clock]  || param_pins[:sck]  || param_pins[:clk]

        # Clean up the params hash.
        [:poci, :miso, :pico, :mosi, :sck, :clk].each { |key| param_pins.delete(key) }

        # Validate param_pins.
        raise ArgumentError, "either output or input pin required" unless param_pins[:input] || param_pins[:output]
        raise ArgumentError, "clock pin required" unless param_pins[:clock]
      end

      def initialize_pins(options={})
        proxy_pin :clock,   DigitalIO::CBitBang
        proxy_pin :output,  DigitalIO::CBitBang if pins[:output]
        proxy_pin :input,   DigitalIO::CBitBang if pins[:input]
      end

      def transfer(select_pin, write: [], read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
        board.spi_bb_transfer select_pin, clock: pins[:clock], output: pins[:output], input: pins[:input],
                                          write: write, read: read, mode: mode, bit_order: bit_order
      end

      def listen(select_pin, read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
        board.spi_bb_listen select_pin, clock: pins[:clock], input: pins[:input],
                                        read: read, mode: mode, bit_order: bit_order
      end

      # Uses regular Board#spi_stop since listeners are shared.
      def stop(pin)
        board.spi_stop(pin)
      end

      # Delegate these to board so peripherals can initialize their select pins.
      def set_pin_mode(*args)
        board.set_pin_mode(*args)
      end

      def convert_pin(pin)
        board.convert_pin(pin)
      end

      # Add peripheral to self and the board. It gets callbacks directly from the board.
      def add_component(component)
        # Ignore components with no select pin. Mostly for APA102.
        return unless component.pin

        pins = components.map { |c| c.pin }
        if pins.include? component.pin
          raise ArgumentError, "duplicate select pin for #{component}"
        end

        components << component
        board.add_component(component)
      end

      # Remove peripheral from self and the board.
      def remove_component(component)
        components.delete(component)
        board.remove_component(component)
      end
    end
  end
end
