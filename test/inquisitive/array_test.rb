require 'test_helper'

class InquisitiveArrayTest < Test

  def array
    Inquisitive::Array.new @raw_array
  end

  include ArrayTests

end
