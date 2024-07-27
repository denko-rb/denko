#
# Diagnostic to confirm board is receiving binary data
# (in aux message) properly.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
echo  = Denko::Connection::BinaryEcho.new(board: board, pin: 253)

min_byte = 0
max_byte = 255

expected_result = (min_byte..max_byte).to_a.join(',') << ','

waiting = false
wait_mutex = Mutex.new

echo.on_data do |data|
  if data == expected_result
    puts "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - Echo received"
    wait_mutex.synchronize { waiting = false }
  end
end

loop do
  wait_mutex.synchronize do
    unless waiting
      echo.test_range(min: min_byte, max: max_byte)
      waiting = true
    end
  end
  sleep 0.001
end
