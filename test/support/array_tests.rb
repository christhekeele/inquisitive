module ArrayTests
  def test_match
    assert @array.postgres?
  end
  def test_miss
    refute @array.sql_server?
  end
  def test_negative_match
    assert @array.exclude.sql_server?
  end
  def test_negative_miss
    refute @array.exclude.postgres?
  end
  def test_double_negative_match
    assert @array.exclude.exclude.postgres?
  end
  def test_double_negative_miss
    refute @array.exclude.exclude.sql_server?
  end
  def test_missing_question_mark
    assert_raises(NoMethodError) { @array.postgres }
  end
  def test_respond_to
    assert_respond_to @array, :postgres?
  end
end
