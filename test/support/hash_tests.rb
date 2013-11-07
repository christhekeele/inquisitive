module HashTests
  def test_key_match
    assert @hash.authentication?
  end
  def test_key_miss
    refute @hash.registration?
  end
  def test_key_negative_match
    assert @hash.no.registration?
  end
  def test_key_negative_miss
    refute @hash.no.authentication?
  end
  def test_key_double_negative_match
    assert @hash.no.no.authentication?
  end
  def test_key_double_negative_miss
    refute @hash.no.no.registration?
  end
  def test_key_respond_to
    assert_respond_to @hash, :authentication?
  end
end
