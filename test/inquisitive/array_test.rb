require 'test_helper'

module Inquisitive
  class ArrayTest < Test

    def array
      Inquisitive::Array.new @raw_array
    end

    include ArrayTests
  end
end
