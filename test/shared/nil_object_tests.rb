module NilObjectTests
  def test_nil_object_value_type
    assert_instance_of Inquisitive::NilClass, nil_object
  end

  def test_nil_object_chains
    assert_instance_of Inquisitive::NilClass, nil_object.chain
  end

  def test_nil_object_acts_as_black_hole
    assert nil_object.respond_to? :anything
  end

  def test_nil_object_match
    assert nil_object.nil?
  end
  def test_nil_object_miss
    refute nil_object.anything_else?
  end
  def test_nil_object_presence_predicate
    refute nil_object.present?
  end
  def test_nil_object_presence_predicate_negataive
    assert nil_object.not.present?
  end
  def test_nil_object_presence_predicate_double_negataive
    refute nil_object.not.not.present?
  end

  def test_nil_object_string_interface
    string = nil_object
    refute string.production?
  end
  def test_nil_object_string_interface_negative
    string = nil_object
    assert string.not.development?
  end
  def test_nil_object_string_interface_double_negative
    string = nil_object
    refute string.not.not.development?
  end

  def test_nil_object_array_interface
    array = nil_object
    refute array.production?
  end
  def test_nil_object_array_interface_negative
    array = nil_object
    assert array.exclude.development?
  end
  def test_nil_object_array_interface_double_negative
    array = nil_object
    refute array.exclude.exclude.development?
  end

  def test_nil_object_hash_interface
    hash = nil_object
    refute hash.production?
  end
  def test_nil_object_hash_interface_negative
    hash = nil_object
    assert hash.no.development?
  end
  def test_nil_object_hash_interface_double_negative
    hash = nil_object
    refute hash.no.no.development?
  end

  def test_nil_coercable_to_empty_string
    assert_equal nil_object.to_str, ""
  end

end
