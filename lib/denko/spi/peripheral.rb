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

        def pre_callback_filter(message)
          if message.class == Array
            # Byte array coming from PiBoard.
            return message
          else
            # Split up comma delimited bytes coming from a microcontroller.
            return message.split(",").map { |b| b.to_i }
          end
        end
      end

      module ChipSelectBehavior
        include Behaviors::SinglePin
        include Behaviors::Callbacks
        include Behaviors::Lifecycle

        before_initialize do
          # It actually functions as an output.
          params[:mode] = :output

          # But we can't claim it on Linux (the SPI hardware handles it), so don't.
          if Object.const_defined?("Denko::PiBoard")
            bus = params[:bus] || params[:board]
            if bus.board.class.ancestors.include?(Denko::PiBoard)
              params[:mode] = nil
            end
          end
        end
      end

      class ChipSelect
        include ChipSelectBehavior
      end

      module SinglePin
        include Core
        include ChipSelectBehavior

        def select_pin
          pin
        end
      end

      module MultiPin
        include Core
        include Behaviors::MultiPin
        include Behaviors::Lifecycle

        def select_pin
          select.pin
        end

        after_initialize do
          proxy_pin :select, ChipSelect, { board: bus.board, mode: :output }
          select.add_callback(:peripheral_forwarder) { |data| self.update(data) }
        end
      end
    end
  end
end
