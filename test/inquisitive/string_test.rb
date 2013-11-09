require 'test_helper'

class StringTest < Test

  def string
    Inquisitive::String.new @raw_string
  end

  include StringTests

end
