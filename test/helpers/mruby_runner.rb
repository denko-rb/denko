# Stub out require_relative to avoid issues.
def require_relative(*args)
end

# Load minimal Minitest clone for mruby.
minitest_source = "#{File.dirname(__FILE__)}/mruby_minitest.rb"
eval(File.read(minitest_source))

# Test Display::Canvas.
canvas_test = "#{File.dirname(__FILE__)}/../display/canvas_test.rb"
eval(File.read(canvas_test))

Minitest::Test.run_all_tests
