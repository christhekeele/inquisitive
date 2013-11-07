require 'test_helper'
require 'inquisitive'

module Inquisitive
  class HashTest < Test
    def setup
      super
      @hash = Inquisitive::Hash.new @raw_hash
      @string = @hash.in
      @array = @hash.databases
    end

    include HashTests

    def test_string_value_type
      assert_instance_of Inquisitive::String, @string
    end
    include StringTests

    def test_array_value_type
      assert_instance_of Inquisitive::Array, @array
    end
    include ArrayTests
  end
end
