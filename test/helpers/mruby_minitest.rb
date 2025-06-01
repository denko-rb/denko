# Minimal implementation of Minitest for mruby.
# Only handles #assert, #refute, and #assert_equal.
module Minitest
  class AssertionError < StandardError
  end

  class Test
    @@test_count = 0
    @@failures   = []
    @@errors     = []
    @@assertions = 0

    def self.run_all_tests
      @@start_time = Time.now

      test_classes = []
      ObjectSpace.each_object(Class) do |klass|
        test_classes << klass if (klass < Minitest::Test && klass != Minitest::Test)
      end

      test_classes.each { |c| c.run_tests }

      @@finish_time = Time.now

      report_results
    end

    def self.run_tests
      test_methods = instance_methods.select { |method| method.to_s.start_with?("test_") }

      test_methods.each do |test_method|
        @@test_count += 1
        test_instance = new

        begin
          test_instance.setup if test_instance.respond_to?(:setup)
          test_instance.send(test_method)
          print "."
        rescue => e
          if e.is_a?(AssertionError)
            @@failures << "#{self.name}##{test_method}: #{e.message}"
            print "F"
          else
            @@errors << "#{self.name}##{test_method}: #{e.class} - #{e.message}"
            print "E"
          end
        ensure
          begin
            test_instance.teardown if test_instance.respond_to?(:teardown)
          rescue => e
            @@errors << "#{self.name}##{test_method} (teardown): #{e.class} - #{e.message}"
          end
        end
      end
    end

    def self.report_results
      puts "\n\nFinished in #{(@@finish_time - @@start_time).round(6)}s"

      puts "#{@@test_count} tests, #{@@assertions} assertions, #{@@failures.length} failures, #{@@errors.length} errors"

      unless @@failures.empty?
        puts "\nFailures:"
        @@failures.each_with_index do |failure, i|
          puts "#{i + 1}) #{failure}"
        end
      end

      unless @@errors.empty?
        puts "\nErrors:"
        @@errors.each_with_index do |error, i|
          puts "#{i + 1}) #{error}"
        end
      end
    end

    def assert(condition, message = "Assertion failed")
      @@assertions += 1
      raise AssertionError.new(message) unless condition
    end

    def refute(condition, message = "Refutation failed - expected falsy value")
      @@assertions += 1
      raise AssertionError.new(message) if condition
    end

    def assert_equal(expected, actual, message = nil)
      @@assertions += 1
      unless expected == actual
        msg = message || "Expected #{expected.inspect}, got #{actual.inspect}"
        raise AssertionError.new(msg)
      end
    end
  end
end
