module HashTests
  def test_hash_value_type
    assert_instance_of Inquisitive::Hash, hash
  end

  def test_hash_match
    assert hash.authentication?
  end
  def test_hash_miss
    refute hash.registration?
  end

  def test_hash_method_access_implicit_nil
    assert_instance_of Inquisitive::NilClass, hash.missing_key
  end
  def test_hash_method_access_explicit_nil
    assert_instance_of Inquisitive::NilClass, hash.nothing
  end
  def test_hash_method_access_string
    assert_instance_of Inquisitive::String, hash.in
  end
  def test_hash_method_access_array
    assert_instance_of Inquisitive::Array, hash.databases
  end
  def test_hash_method_access_hash
    assert_instance_of Inquisitive::Hash, hash.nested
  end

  def test_hash_access_implicit_nil
    assert_instance_of Inquisitive::NilClass, hash[:missing_key]
  end
  def test_hash_access_explicit_nil
    assert_instance_of Inquisitive::NilClass, hash[:nothing]
  end
  def test_hash_access_string
    assert_instance_of Inquisitive::String, hash[:in]
  end
  def test_hash_access_array
    assert_instance_of Inquisitive::Array, hash[:databases]
  end
  def test_hash_access_hash
    assert_instance_of Inquisitive::Hash, hash[:nested]
  end

  def test_hash_fetch_implicit_nil
    assert_equal hash.fetch(:missing_key, @default_value), @default_value
  end
  def test_hash_fetch_explicit_nil
    assert_equal hash.fetch(:nothing, @default_value), @default_value
  end
  def test_hash_present_value
    assert_equal hash.fetch(:in), @raw_string
  end

  def test_hash_negative_match
    assert hash.no.registration?
  end
  def test_hash_negative_miss
    refute hash.no.authentication?
  end

  def test_hash_double_negative_match
    assert hash.no.no.authentication?
  end
  def test_hash_double_negative_miss
    refute hash.no.no.registration?
  end

  def test_hash_respond_to
    assert_respond_to hash, :authentication?
  end
end
