module StringTests
  def test_match
    assert string.production?
  end
  def test_miss
    refute string.development?
  end
  def test_negative_match
    assert string.not.development?
  end
  def test_negative_miss
    refute string.not.production?
  end
  def test_double_negative_match
    assert string.not.not.production?
  end
  def test_double_negative_miss
    refute string.not.not.development?
  end
  def test_missing_question_mark
    assert_raises(NoMethodError) { string.production }
  end
  def test_respond_to
    assert_respond_to string, :development?
  end
end
