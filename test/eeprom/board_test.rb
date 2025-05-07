require_relative '../test_helper'

class BoardMock < Denko::Board
  # Fake EEPROM
  def eeprom_stub
    @eeprom_stub ||= Array.new(eeprom_length){255}
  end

  def eeprom_read(start_address, length)
    # Pack it up like a string coming from the board and update.
    string = eeprom_stub[start_address, length].map{ |x| x.to_s }.join(",")
    self.update("254:#{start_address}-#{string}\n")
  end

  def eeprom_write(start_address, bytes)
    eeprom_stub[start_address, bytes.length] = bytes
  end
end

class EEPROMBoardTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= board.eeprom
  end

  def test_pin_ee
    assert_equal part.pin, 254
  end

  def test_individual_read_write
    assert_equal 255, part[20]
    part[20] = 111
    assert_equal 111, part[20]
  end

  def test_range_read_write
    data = [15, 23, 50, 12, 11]
    index = 11
    part[index] = data
    assert_equal data, part[index..(index+data.length-1)]
  end
end
