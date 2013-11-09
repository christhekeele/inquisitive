module HashTests
  def test_hash_match
    assert hash.authentication?
  end
  def test_hash_miss
    refute hash.registration?
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
