require "rubygems"
require "minitest/autorun"
require "simplecov"

SimpleCov.start do
  add_filter "/test"
end

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

require "support/string_tests"
require "support/array_tests"
require "support/hash_tests"
require "support/environment_tests"

require "inquisitive"
