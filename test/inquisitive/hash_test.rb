require 'test_helper'
require 'inquisitive'

module Inquisitive
  class HashTest < Test

    def string
      hash.in
    end
    def array
      hash.databases
    end
    def hash
      Inquisitive::Hash.new @raw_hash
    end

    include HashTests

    def test_string_value_type
      assert_instance_of Inquisitive::String, string
    end
    include StringTests

    def test_array_value_type
      assert_instance_of Inquisitive::Array, array
    end
    include ArrayTests
  end
end
