module StringTests
  def test_string_value_type
    assert_instance_of Inquisitive::String, string
  end

  def test_string_match
    assert string.production?
  end
  def test_string_miss
    refute string.development?
  end

  def test_string_negative_match
    assert string.not.development?
  end
  def test_string_negative_miss
    refute string.not.production?
  end

  def test_string_double_negative_match
    assert string.not.not.production?
  end
  def test_string_double_negative_miss
    refute string.not.not.development?
  end

  def test_string_respond_to
    assert_respond_to string, :development?
  end
  def test_string_method_missing
    assert_raises(NoMethodError) { string.undefined }
  end
end
