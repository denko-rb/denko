module Denko
  module Connection
    module FlowControl
      SLEEP_TIME = 0.001

      # Let Board object tell us the remote buffer size after parsing handshake.
      def remote_buffer_size=(size)
        @transit_mutex.synchronize { @remote_buffer_size = size }
      end

      def initialize(*args, **kwargs)
        super(*args, **kwargs)
        # Start with minimum known buffer size. Board will update after handshake.
        # WARNING: If not updated, and ack threshold on the board is > minimum,
        # FlowControl will stop sending data, and appear to hang. Fix this.
        @remote_buffer_size = 63
        reset_flow_control
        tx_resume
      end

      def write(message, tx_halt_after=nil)
        @write_buffer_mutex.synchronize do
          @write_buffer << message

          # Optionally halt transmission after this message.
          # See comments on Board#write_and_halt for more info.
          @tx_halt_points << @write_buffer.length if tx_halt_after
        end
      end

      def writing?
        @write_buffer_mutex.synchronize { !@write_buffer.empty? }
      end

    private

      def reset_flow_control
        @tx_ready_mutex ||= Mutex.new
        @transit_mutex  ||= Mutex.new
        @transit_mutex.synchronize { @transit_bytes = 0 }

        @write_buffer_mutex ||= Mutex.new
        @write_buffer_mutex.synchronize do
          @write_buffer = String.new
          @tx_halt_points = []
        end
      end

      def write_from_buffer
        fragment = nil
        halt_after_fragment = false

        @write_buffer_mutex.synchronize do
          break if @write_buffer.empty?

          # Try to send the entire buffer unless a halt point is coming up.
          if @tx_halt_points.empty?
            limit = @write_buffer.length
          # Don't send beyond the first halt point if one exists.
          else
            limit = @tx_halt_points[0]
          end
          # Try to reserve limit bytes on the remote read buffer.
          bytes = reserve_bytes(limit)

          if bytes > 0
            # Take fragment of bytes length off the write buffer.
            fragment = @write_buffer[0..(bytes-1)]
            @write_buffer = @write_buffer[bytes..-1]

            # Update the halt points to reflect bytes removed.
            @tx_halt_points.map! { |length| length - bytes }

            # If the first halt point was reached, delete it, and halt after writing fragment.
            if @tx_halt_points[0] == 0
              @tx_halt_points.shift
              halt_after_fragment = true
            end
          end
        end

        return wait unless fragment

        loop do
          # Write fragment if @tx_ready.
          @tx_ready_mutex.synchronize do
            if @tx_ready
              _write fragment
              @tx_ready = false if halt_after_fragment
              return
            end
          end
          # Else wait outside the @tx_ready_mutex. Allows read thread to update @tx_ready.
          wait
        end
      end

      # Keep transit mutex as short as possible, by only reserving bytes, and writing outside.
      def reserve_bytes(length)
        @transit_mutex.synchronize do
          available = @remote_buffer_size - @transit_bytes
          reserved = (length > available) ? available : length
          @transit_bytes += reserved
          reserved
        end
      end

      def read
        line = _read

        if line
          case line[0..2]
          # Board read (freed) this many bytes from its input buffer.
          when "Rx:"
            remove_transit_bytes(line.split(/:/)[1].to_i)
            line = nil
          # Board says to resume transmission.
          when "Rdy"
            tx_resume
            line = nil
          # Board says to halt transmission.
          when "Hlt"
            tx_halt
            line = nil
          # Print debug lines.
          when "DBG"
            puts line.inspect
            line = nil
          end
        else
          wait
        end

        return line
      end

      def wait
        sleep SLEEP_TIME
      end

      def tx_halt
        @tx_ready_mutex.synchronize { @tx_ready = false }
      end

      def tx_resume
        @tx_ready_mutex.synchronize { @tx_ready = true }
      end

      def remove_transit_bytes(value)
        @transit_mutex.synchronize do
          @transit_bytes = @transit_bytes - value
          @transit_bytes = 0 if @transit_bytes < 0
        end
      end
    end
  end
end
