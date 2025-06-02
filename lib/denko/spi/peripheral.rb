module Denko
  module SPI
    class ChipSelect
      include Behaviors::SinglePin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle

      before_initialize do
        # It actually functions as an output.
        params[:mode] = :output

        # But we can't claim it on Linux (the SPI hardware handles it), so don't.
        if !Denko.mruby? && Object.const_defined?("Denko::PiBoard")
          bus = params[:bus] || params[:board]
          if board.class.ancestors.include?(Denko::PiBoard)
            params[:mode] = nil
          end
        end
      end
    end

    module Peripheral
      include Behaviors::MultiPin
      include Behaviors::BusPeripheral
      include Behaviors::Callbacks
      include Behaviors::Lifecycle

      # We have the SPI bus set as our board, but the select pin,
      # and any other pins, need to attach to the underlying board.
      def proxy_pin(*args, **kwargs)
        kwargs[:board] = bus.board
        super(*args, **kwargs)
      end

      # If given just one value in pin:, treat that as the select pin.
      before_initialize do
        if (params[:pin].class != Hash) && (!params[:pins])
          params[:pins] = { select: params[:pin] }
          params[:pin] = nil
        end
      end

      # Chip select pin is always treated as a subcomponent
      def initialize_pins(params={})
        super(params)
        proxy_pin :select, ChipSelect, mode: :output
      end

      # SelectPin is a separate component that receives updates from Board.
      # Forward them to the Peripheral
      after_initialize do
        select.add_callback(:peripheral_forwarder) { |data| self.update(data) }
      end

      def ensure_byte_array(message)
        if message.class == Array
          # Byte array coming from PiBoard.
          return message
        else
          # Split up comma delimited bytes coming from a microcontroller.
          return message.split(",").map { |b| b.to_i }
        end
      end

      def update(message)
        super(ensure_byte_array(message))
      end

      #
      # SPI Properties
      #
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
        bus.transfer(select.pin, write: write, read: read, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_write(byte_array)
        bus.transfer(select.pin, write: byte_array, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_read(num_bytes)
        bus.transfer(select.pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_listen(num_bytes)
        bus.listen(select.pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_stop
        bus.stop(select.pin)
      end
    end
  end
end
