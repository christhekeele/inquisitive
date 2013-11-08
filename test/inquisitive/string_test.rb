require 'test_helper'

module Inquisitive
  class StringTest < Test

    def string
      Inquisitive::String.new @raw_string
    end

    include StringTests
  end
end
