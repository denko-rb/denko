module Denko
  module Message
    BYTE_MAX = 255
    VAL_MIN = 0
    VAL_MAX = 9999

    def self.encode(command: nil, pin: nil, value: nil, aux_message: nil)
      # Optimized single byte binary message for digital write on pins 0..63.
      if (command == 1) && (pin < 64) && (value == 1 || value == 0)
        return (pin | 0b10000000 | (value << 6)).chr
      end

      # Start building message backwards with aux_message first.
      if aux_message
        # Convert it to String.
        aux_message = aux_message.to_s

        # Validate aux_message before escaping characters.
        raise ArgumentError, 'aux_message is limited to 528 characters' if aux_message.length > 784

        # Escape \ and \n.
        aux_message = aux_message.gsub("\\","\\\\\\\\").gsub("\n", "\\\n")

        # Start message with aux_message.
        message = ".#{aux_message}"
      else
        # Or start with empty message.
        message = ""
      end

      # Prepend value
      if value
        # Validate value
        if (value.class != Integer || value < VAL_MIN || value > VAL_MAX)
          raise ArgumentError, "value must be integer in range #{VAL_MIN} to #{VAL_MAX}"
        end

        message = ".#{value}#{message}"
      elsif !message.empty?
        message = ".#{message}"
      end

      # Prepend pin
      if pin
        # Validate pin
        if (pin.class != Integer || pin < 0 || pin > BYTE_MAX)
          raise ArgumentError, 'pin must be integer in range 0 to 255'
        end

        message = ".#{pin}#{message}"
      elsif !message.empty?
        message = ".#{message}"
      end

      # Validate command
      raise ArgumentError, 'command missing from message' unless command
      if command.class != Integer || command < 0 || command > BYTE_MAX
        raise ArgumentError, 'command must be Integer in range 0 to 255'
      end

      # Prepend command and append newline.
      message = "#{command}#{message}\n"
    end

    def self.pack(type, data, min: nil, max: nil)
      # Always pack as little endian.
      template =  case type
                  when :uint64  then 'Q<*'
                  when :uint32  then 'L<*'
                  when :uint16  then 'S<*'
                  when :uint8   then 'C*'
                  else raise ArgumentError, "unsupported pack format '#{type}'"
                  end

      # Can pass a single integer to get packed if we always [] then flatten.
      str = [data].flatten.pack(template)

      # Enforce min and max.
      if min && str.length < min
        raise ArgumentError, "too few bytes given (expected at least #{min})"
      end
      if max && str.length > max
        raise ArgumentError, "too many bytes given (expected at most #{max})"
      end

      str
    end
  end
end
