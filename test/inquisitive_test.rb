require 'test_helper'

class InquisitiveTest < Test
  Helpers = Module.new.extend Inquisitive
  HashWithIndifferentAccess ||= Inquisitive::HashWithIndifferentAccess

  def setup
    super
    @symbol = :a
    @numeric = 1
    @class = if Object.const_defined?(:Misc)
      Misc
    else
      Object.const_set(:Misc, Class.new)
    end
    @object = @class.new
  end

####
# CONVERSION
##
  def test_converted_false_equality
    assert_equal Inquisitive[false], false
  end
  def test_converted_true_equality
    assert_equal Inquisitive[true], true
  end
  def test_converted_numeric_equality
    assert_equal Inquisitive[@numeric], @numeric
  end
  def test_converted_symbol_equality
    assert_equal Inquisitive[@symbol], @symbol
  end
  def test_converted_class_equality
    assert_equal Inquisitive[@class], @class
  end
  def test_converted_object_equality
    assert_equal Inquisitive[@object], @object
  end

  def test_converted_nil_object_ancestry
    assert_kind_of NilClass, Inquisitive[nil]
    assert Inquisitive[nil] === NilClass
  end
  def test_converted_nil_object_instanciation
    assert_kind_of Inquisitive::NilClass, Inquisitive[nil]
  end
  def test_converted_nil_object_equality
    assert_equal Inquisitive[nil], @raw_nil_object
  end

  def test_converted_string_ancestry
    assert_kind_of String, Inquisitive[@raw_string]
    assert Inquisitive[@raw_string] === String
  end
  def test_converted_string_instanciation
    assert_kind_of Inquisitive::String, Inquisitive[@raw_string]
  end
  def test_converted_string_equality
    assert_equal Inquisitive[@raw_string], @raw_string
  end

  def test_converted_array_ancestry
    assert_kind_of Array, Inquisitive[@raw_array]
    assert Inquisitive[@raw_array] === Array
  end
  def test_converted_array_instanciation
    assert_kind_of Inquisitive::Array, Inquisitive[@raw_array]
  end
  def test_converted_array_equality
    assert_equal Inquisitive[@raw_array], @raw_array
  end

  def test_converted_hash_ancestry
    assert_kind_of Hash, Inquisitive[@raw_hash]
    assert Inquisitive[@raw_hash] === Hash
  end
  def test_converted_hash_instanciation
    assert_kind_of Inquisitive::Hash, Inquisitive[@raw_hash]
  end
  def test_converted_hash_equality
    assert_equal Inquisitive[@raw_hash], HashWithIndifferentAccess.new(@raw_hash)
  end

####
# PRESENCE
##
  def test_presence_of_nil
    refute Inquisitive.present? nil
  end
  def test_presence_of_false
    refute Inquisitive.present? false
  end
  def test_presence_of_true
    assert Inquisitive.present? true
  end
  def test_presence_of_numeric
    assert Inquisitive.present? @numeric
  end
  def test_presence_of_symbol
    assert Inquisitive.present? @symbol
  end
  def test_presence_of_class
    assert Inquisitive.present? @class
  end
  def test_presence_of_object
    assert Inquisitive.present? @object
  end

  def test_presence_of_non_blank_strings
    assert Inquisitive.present? @raw_string
  end
  def test_presence_of_blank_strings
    refute Inquisitive.present? ""
  end

  def test_presence_of_non_empty_arrays
    assert Inquisitive.present? @raw_array
  end
  def test_presence_of_partially_empty_string_array_elements
    assert Inquisitive.present? [nil, @raw_string]
  end
  def test_presence_of_partially_empty_hash_array_elements
    assert Inquisitive.present? [nil, @raw_string]
  end
  def test_presence_of_empty_array_elements
    refute Inquisitive.present? [nil, "", [], {a: nil}]
  end
  def test_presence_of_empty_arrays
    refute Inquisitive.present? []
  end

  def test_presence_of_non_empty_hashes
    assert Inquisitive.present? @raw_hash
  end
  def test_presence_of_partially_empty_string_hash_elements
    assert Inquisitive.present?({a: nil, b: @raw_string})
  end
  def test_presence_of_partially_empty_array_hash_elements
    assert Inquisitive.present?({a: nil, b: @raw_array})
  end
  def test_presence_of_empty_hash_elements
    refute Inquisitive.present?({a: nil, b: "", c: [], d: {a: nil}})
  end
  def test_presence_of_empty_hashes
    refute Inquisitive.present?({})
  end

####
# HELPERS
##
  def test_found_symbol_predicate_method_helper
    assert Helpers.send :predicate_method?, :foo?
  end
  def test_found_string_predicate_method_helper
    assert Helpers.send :predicate_method?, "foo?"
  end
  def test_missing_symbol_predicate_method_helper
    refute Helpers.send :predicate_method?, :foo
  end
  def test_missing_string_predicate_method_helper
    refute Helpers.send :predicate_method?, "foo"
  end

  def test_symbol_predication_helper
    assert_equal Helpers.send(:predication, :foo?),  'foo'
  end
  def test_string_predication_helper
    assert_equal Helpers.send(:predication, "foo?"), 'foo'
  end
end
