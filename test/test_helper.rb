require "rubygems"

if ENV['CIRCLE_ARTIFACTS']
  require "simplecov"
  SimpleCov.coverage_dir File.join("..", "..", "..", ENV['CIRCLE_ARTIFACTS'], "coverage")
  require 'simplecov-badge'
  SimpleCov::Formatter::BadgeFormatter.badge_title = 'coverage'
  SimpleCov.formatter = SimpleCov::Formatter::BadgeFormatter
end

if ENV['LOCAL']
  require "simplecov"
  SimpleCov.coverage_dir '.coverage'
end

if defined? SimpleCov
  SimpleCov.start do
    add_filter "/test"
  end
end

require "minitest/autorun"

class Test < MiniTest::Test

  def assert_change(lambda_getter)
    old = lambda_getter.call
    yield
    refute_equal old, lambda_getter.call
  end

  def refute_change(lambda_getter)
    old = lambda_getter.call
    yield
    assert_equal old, lambda_getter.call
  end

  def refute_raise
    nothing_raised = true
    message = 'Nothing raised.'
    begin
      yield
    rescue => e
      nothing_raised = false
      message = "Expected nothing to be raised, caught: #{e.exception}:\n" \
                "#{e.backtrace.join("\n")}"
    end
    assert nothing_raised, message
  end

  def setup
    @raw_string = 'production'
    @raw_array  = %w[mysql postgres sqlite]
    @raw_hash   = {
      authentication: true,
      in: @raw_string,
      databases: @raw_array
    }
  end

end

class EnvironmentTest < Test

  def setup
    super
    Object.const_set :App, Module.new
    App.extend Inquisitive::Environment
  end
  def teardown
    super
    Object.send :remove_const, :App
  end

end

require "shared/string_tests"
require "shared/array_tests"
require "shared/hash_tests"
require "shared/combinatorial_environment_tests"

require "inquisitive"
