require_relative '../test_helper'

class SevenSegmentLEDTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board,
      pins: {anode: 11, a: 12, b: 13, c: 3, d: 4, e: 5, f: 10, g: 9} }
  end

  def part
    @part ||= Denko::LED::SevenSegment.new(options)
  end

  def test_proxies
    segments = [:a, :b, :c, :d, :e, :f, :g]
    segments.each do |segment|
      assert_equal Denko::DigitalIO::Output, part.proxies[segment].class
    end
  end

  def test_clears_during_initialize
    # Avoid reusing pins which would raise a Board error.
    def part.initialize_pins; end

    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:clear, mock) do
      part.send(:initialize, options)
    end
    mock.verify
  end

  def test_turns_on_during_initialize
    # Avoid reusing pins which would raise a Board error.
    def part.initialize_pins; end

    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:on, mock) do
      part.send(:initialize, options)
    end
    mock.verify
  end

  def test_on
    mock = Minitest::Mock.new.expect :high, nil
    part.stub(:anode, mock) do
      part.on
    end
    mock.verify
  end

  def test_off
    mock = Minitest::Mock.new.expect :low, nil
    part.stub(:anode, mock) do
      part.off
    end
    mock.verify
  end

  def test_scroll
    mock = Minitest::Mock.new
    mock.expect :call, nil, ['h']
    mock.expect :call, nil, ['i']
    part.stub(:write, mock) do
      part.display('hi')
    end
    mock.verify
  end

  def test_display_ensures_on
    part.off
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:on, mock) do
      part.display(1)
    end
    mock.verify
  end

  def test_write_clears_if_unknown_char
    # Turn all the segments on.
    part.display('8')

    # Expect every segment to get #write(1). Inverted logic because anode.
    mocks = []
    part.segments.each do
      mocks << Minitest::Mock.new.expect(:call, nil, [1])
    end
    part.segments[0].stub(:digital_write, mocks[0]) do
      part.segments[1].stub(:digital_write, mocks[1]) do
        part.segments[2].stub(:digital_write, mocks[2]) do
          part.segments[3].stub(:digital_write, mocks[3]) do
            part.segments[4].stub(:digital_write, mocks[4]) do
              part.segments[5].stub(:digital_write, mocks[5]) do
                part.segments[6].stub(:digital_write, mocks[6]) do
                  part.display('+')
                end
              end
            end
          end
        end
      end
    end
    mocks.each { |mock| mock.verify}
  end
  # Test with cathode
end
