module Denko
  module SPI
    module Peripheral
      module Core
        include Behaviors::BusPeripheral
        include Behaviors::Callbacks

        def spi_frequency
          @spi_frequency ||= params[:spi_frequency] || 1_000_000
        end

        def spi_mode
          @spi_mode ||= params[:spi_mode] || 0
        end

        def spi_bit_order
          @spi_bit_order ||= params[:spi_bit_order] || :msbfirst
        end

        attr_writer :spi_frequency, :spi_mode, :spi_bit_order

        #
        # Delegate methods to the bus.
        #
        def spi_transfer(write: [], read: 0)
          bus.transfer(select_pin, write: write, read: read, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
        end

        def spi_write(byte_array)
          bus.transfer(select_pin, write: byte_array, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
        end

        def spi_read(num_bytes)
          bus.transfer(select_pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
        end

        def spi_listen(num_bytes)
          bus.listen(select_pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
        end

        def spi_stop
          bus.stop(select_pin)
        end
      end

      module SinglePin
        include Core
        include Behaviors::OutputPin

        def select_pin
          pin
        end
      end

      module MultiPin
        include Core
        include Behaviors::MultiPin

        def initialize_pins(options={})
          super(options)
          proxy_pin :select, DigitalIO::Output, board: bus.board
        end

        def select_pin
          select.pin
        end
      end
    end
  end
end
