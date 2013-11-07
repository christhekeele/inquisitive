require "rubygems"
require "minitest/autorun"
require "simplecov"

SimpleCov.start do
  add_filter "/test"
end

class Test < MiniTest::Test
  def setup
    @raw_string = 'production'
    @raw_array  = %w[mysql postgres sqlite]
    @raw_hash   = {
      authentication: true,
      in: @raw_string,
      databases: @raw_array,
      ignorable: { junk: [ "" ] }
    }
  end
end

require "support/string_tests"
require "support/array_tests"
require "support/hash_tests"

require "inquisitive"
