require 'test_helper'

class UtilsTest
  Utils = Module.new.extend Inquisitive::Utils

  def test_found_symbol_predicate_method_helper
    assert Utils.send(:predicate_method?, :foo?)
  end
  def test_found_string_predicate_method_helper
    assert Utils.send(:predicate_method?, "foo?")
  end
  def test_missing_symbol_predicate_method_helper
    refute Utils.send(:predicate_method?, :foo)
  end
  def test_missing_string_predicate_method_helper
    refute Utils.send(:predicate_method?, "foo")
  end

  def test_symbol_predication_helper
    assert_equal Utils.send(:predication, :foo?),  'foo'
  end
  def test_string_predication_helper
    assert_equal Utils.send(:predication, "foo?"), 'foo'
  end

end
