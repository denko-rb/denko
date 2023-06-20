require_relative '../test_helper'

class OneWireHelper < Minitest::Test
  
  def test_with_valid_crc
    assert Denko::OneWire::Helper.crc_check(18086456125349333800)
    assert Denko::OneWire::Helper.crc_check([121, 117, 144, 185, 6, 165, 43, 26])
  end
  
  def test_with_invalid_crc
    refute Denko::OneWire::Helper.crc_check(18086456125349333801)
  end
  
  def test_arbitrary_length_read
    assert Denko::OneWire::Helper.crc_check([181, 1, 75, 70, 127, 255, 11, 16, 163])
    refute Denko::OneWire::Helper.crc_check([181, 1, 75, 70, 127, 255, 11, 16, 164])
  end
end
