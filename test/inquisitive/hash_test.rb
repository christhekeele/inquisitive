require 'test_helper'

class HashTest < Test

  def hash
    Inquisitive::Hash.new @raw_hash
  end
  include HashTests

  def string
    hash.in
  end
  include StringTests

  def array
    hash.databases
  end
  include ArrayTests

end
