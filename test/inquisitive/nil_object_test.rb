require 'test_helper'

class NilObjectTest < Test

  def nil_object
    Inquisitive::NilClass.new
  end

  include NilObjectTests

end
